'''
Performs static camera background subtraction on the specified video file.

Author: Julian Ryde

Usage:

python background_subtraction.py video.mov output_path
'''

import numpy as np
import scipy.ndimage as ndimage
import scipy.stats as stats
import sys
import os

import istare
import istare.video as video

import pylab

visualise = False
pixel_noise = 6
# this is a function of the downsample and should be calculated from always 
# background pixels.  

freq_threshold = 0.2 # proportion of max freq

always_threshold = 20 
# range of the Red channel for always background pixels
def possible_foreground(V):
    '''Determines those pixels that have little variability throughout the 
    entire video and are therefore likely to background pixels which have no 
    activity occur over them.'''
    # ptp is quite a bit faster to compute and for normally distributed 
    # pixel noise is similar to std but does not work for continuous video.
    # Could use std for continously running video
    # Computed only on the red channel for speed
    P = np.ptp(V[:,:,:,0], axis=0)
    #P = np.std(V, axis=3).mean(axis=2)
    inds = P > always_threshold
    return inds

def accumulate_gray(X, debug=False, kde=True):
    assert X.shape[0] == 3
    #rgb_copied = np.zeros((3, X.shape[1]), dtype=np.bool)
    accum = np.zeros((3, 256), dtype=float)
    freqs = np.zeros(X.shape, dtype=float)
    # For interest
    for i in range(3):
        counts = np.bincount(X[i])
        # pad counts upto 256 long so that the smoothing is more accurate
        counts = np.hstack((counts, np.zeros(256 - len(counts)))) 

        # TODO is this really necessary? kde switch helps show that it is?
        # Do a kernel density estimation by convolution with a guassian
        if kde:
            accum[i] = ndimage.gaussian_filter1d(counts.astype(float), pixel_noise)
        else:
            accum[i] = counts
        freqs[i] = accum[i, X[i]]

    # normalise by dividing the freqs of each color by the max for that color
    freqs /= freqs.max(axis=1)[:,np.newaxis]

    if debug:
        return freqs, accum
    else:
        # any channel rare enough is considered foreground
        return np.sum(freqs < freq_threshold, axis=0) > 0

def remove_background(vid,structure=None,iterations=1,output=None,origin=0):
    # create a boolean array where true is foreground
    fore_vid = video.Video(frames=vid.frames, rows=vid.rows, columns=vid.columns, bands=1, dtype=bool)

    # Select only those pixels which experience significant variation at some 
    # point in the video
    V = vid.V
    inds_bool = possible_foreground(V)
    # remove isolated pixels
    opened_inds = ndimage.binary_opening(inds_bool,structure,iterations,output,origin)

    if visualise:
        pylab.ion()
        pylab.figure(2); pylab.clf()
        pylab.imshow(opened_inds)
        pylab.draw()

    pixel_coords = np.asarray(np.where(opened_inds)).T
    print 'Performing background subtraction for %d frames' % len(vid)
    print 'Analysing %d/%d candidate pixels' % (pixel_coords.shape[0], vid.rows*vid.columns)

    for row, col in pixel_coords:
        X = V[ :,row, col, :].T
        copied = accumulate_gray(X)
        fore_vid.V[:,row,col,0] = copied
    return fore_vid

def prepare_output(path):
    '''Makes the output directory creating parent directories where necessary 
    but does not throw an error if it already exists'''
    if not os.path.exists(path):
        os.makedirs(path)

def process_video(vid, loc):
    prepare_output(loc)
    vid.save(loc + 'input.mpg')
    W = remove_background(vid)
    W.colour_map().save(loc + 'background.mpg')
    vid.V[np.logical_not(W.V.squeeze())] = (0,0,0)
    # for comparison output colourspace dt
    #Cdt = vid.colour_space_dt().colour_map()
    vid.save(loc + 'masked.mpg')

if __name__ == '__main__':
    out_dir = '/tmp/background_results/'
    print 'Results directory:', out_dir
    if len(sys.argv) < 2:
        while True:
            vid = istare.random_video(factor=4)
            loc = out_dir + istare.get_ID(vid.source) + '/'
            process_video(vid, loc)
    else:
        vid = istare.get_video(sys.argv[1])
        out_dir = sys.argv[2]
        process_video(vid, out_dir)
