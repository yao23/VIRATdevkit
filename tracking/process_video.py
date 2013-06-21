'''
Reads the file having video file names and performs background subtraction on the videos
corresponding to the these file names.

AUTHOR : Sagar

how to run
python whitelist_background.py path_to_file_list output_directory_path down_sampling_Factor_for_videos
python process_whitelist.py /home/surenkum/datasets/caviar/videos/corridor/caviarcorridor.txt /home/surenkum/datasets/caviar/background-subtraction 2
'''

import sys
#sys.path.append('/home/surenkum/istare_repo/experimental/motion_unit/priyansh')

import istare
import istare.video as video
import istare.background_subtraction as bs
import istare.connected_components as cc
#import sys
import numpy as np
import scipy.io as sio
import os
import h5py

bs.visualise = False

def process_background_whitelist(fname, output_dir, downsample_factor = 4, contour_analysis = False):
    ''' Takes in the video_file path and output directory and performs the processing stated
        in doc_string
    '''
    save_fname = fname.split('/')
    save_fname = save_fname[len(save_fname)-1]
    save_fname = save_fname[0:len(save_fname)-4] + '.hdf5'
    save_fname = os.path.join(output_dir, save_fname)
    vid = video.asvideo(fname, downsample_factor)
    no_back = bs.remove_background(vid)
    output_array = no_back.V
    if contour_analysis:
       output_array = cc.process_video_array(output_array)[0]
    output_array = np.array(output_array)
    hdf5_file = h5py.File(save_fname, 'w')
    dset = hdf5_file.create_dataset('output_array', data = output_array, compression = 'gzip')
    hdf5_file.close()

'''
def process_background_whitelist(list_fname, output_dir, downsample_factor = 4, contour_analysis = False):

    Takes in the video_file path and output directory and performs the aforementioned 
        processing 

    file_handle = open(list_fname)
    lines = file_handle.readlines()
    for fname in lines:
        fname = fname.strip('\n')
        save_fname = fname.split('/')
        my_fname = save_fname[len(save_fname)-1]
        fname = istare.get_video(my_fname)
        save_fname = save_fname[len(save_fname)-1]
        save_fname = save_fname[0:len(save_fname)-4] + '.mat'
        save_fname = os.path.join(output_dir, save_fname)
        video_array = video.video_to_array(fname, '/tmp/video.bin', downsample_factor)
        output_array = bs.remove_background_from_vidarray(video_array)
        if contour_analysis:
            output_array = cc.process_video_array(output_array)[0]
        pylab.close('all')
        output_array = np.array(output_array)
        sio.savemat(save_fname, {'output_array' : output_array},do_compression=True) 
'''     
if __name__ == '__main__':
    if(len(sys.argv) != 4 and len(sys.argv)!=5 and len(sys.argv)!=6):
        print __doc__
        sys.exit()
    if len(sys.argv) == 4 :
        process_background_whitelist(sys.argv[1], sys.argv[2], int(sys.argv[3]))

    if len(sys.argv) == 5 :
        process_background_whitelist(sys.argv[1], sys.argv[2], int(sys.argv[3]), bool(int(sys.argv[4])))

    
# python process_whitelist.py H file output downsampling_factor threshold
