'''
Performs human detection in a specified video

Author: Sagar

Usage: human_detection input_video output_video downsampling_factor threshold

example
python human_detection.py video_file output_file video_downsampling_factor threshold
For given back_ground subtraction threshold is 0.05.
'''

import os
import sys

import cv
import progressbar

import istare
import video
import myimage
import background_subtraction as bs
import numpy as np

video_file = ''
downsampling_factor = 0

# Using this definition from peopledetect.py
def inside(r, q):
    ''' check whether 'q' rectangle lie inside 'r' rectangle.'''
    (rx, ry), (rw, rh) = r
    (qx, qy), (qw, qh) = q
    return rx > qx and ry > qy and rx + rw < qx + qw and ry + rh < qy + qh

# Using code snippet from peopledetect.py
def filter_bounding_boxes(found):
    ''' Post non-maximal suppression processing.'''
    found_filtered = []
    for r in found:
        insidef = False
        for q in found:
            if inside(r, q):
                insidef = True
                break
        if not insidef:
            found_filtered.append(r)
    return found_filtered

def write_header(file_handle, video_file, downsampling_factor, threshold):
    ''' Write basic information life video_path, parameters involved etc.
        to the output file.''' 
    file_handle.write('Header\n')
    file_handle.write(video_file + ',' + str(downsampling_factor) + ',' +
                                                 str(threshold) + '\n')
    file_handle.write('Output format: frame_no, x_min, y_min, x_max, y_max, x_min, y_min, x_max, y_max\n')
    file_handle.write('Each line will have frame_no and bounding box/es for human/s detected in that frame.\n')
    file_handle.write('Data\n')


def write_to_file(frame_no, file_handle, boxes):
    ''' writing each line output to output file.''' 
    file_handle.write(str(frame_no))
    for box in boxes:
        file_handle.write(',' + str(box[0]) + ',' + str(box[1]) 
                        + ',' + str(box[2]) + ',' + str(box[3]) )
    file_handle.write('\n') 
            
def human_detection_processing(vid, W, output_file, threshold = 0.001):
    '''Works directly on Arrays of original and background subtracted videos.'''
    global video_file
    global downsampling_factor
    video_file = vid.source 
    bboxes_bg = open(output_file, 'w')
    bboxes_fg = open(output_file+'r', 'w')

    write_header(bboxes_bg, video_file, downsampling_factor, threshold)
    write_header(bboxes_fg, video_file, downsampling_factor, threshold)


    no_of_frames = len(vid)
    storage = cv.CreateMemStorage(0)
    width = vid.columns
    height = vid.rows
    pbar = progressbar.ProgressBar()
    pbar.maxval = no_of_frames
    print 'Finding humans'
    for i in range(0, no_of_frames):
        pbar.update(i)
        cv_img = myimage.array_image_test(vid.V[ i,:, :, :])
        img_array_bg = W.V[ i,:, :, :]
        found = list(cv.HOGDetectMultiScale(cv_img, storage,
                                            win_stride = (2, 2),
                                            padding = (16, 9), scale = 1.05,
                                            group_threshold = 2))
        found = filter_bounding_boxes(found)
        boxes = []
        raw_boxes = []
        for r in found:
            (rx, ry), (rw, rh) = r
            top_left = list((rx + rw*0.3, ry + rh*0.3))
            bottom_right = list((rx + rw*0.8, ry + rh*0.9))
            if top_left[0] >= width:
                top_left[0] = width - 1
            if top_left[1] >= height:
                top_left[1] = height - 1
            if bottom_right[0] >= width:
                bottom_right[0] = width - 1
            if bottom_right[1] >= height:
                bottom_right[1] = height - 1

            raw_boxes.append((top_left[0], top_left[1], bottom_right[0], bottom_right[1])) 
            img_bounding_box = img_array_bg[top_left[1]:bottom_right[1], top_left[0]:bottom_right[0], 0]
            no_of_foreground_pix = img_bounding_box > 0
            total_area = float(img_bounding_box.shape[0] * img_bounding_box.shape[1])
            per_foreground_pix = no_of_foreground_pix.sum()/total_area
            if per_foreground_pix > threshold:
                boxes.append((top_left[0], top_left[1], bottom_right[0], bottom_right[1])) 
        if boxes != [] :
            #print boxes
            #print raw_boxes
            write_to_file(i, bboxes_bg, boxes)
            write_to_file(i, bboxes_fg, raw_boxes)   
    pbar.finish()
    bboxes_bg.close()
    bboxes_fg.close()    
    return 0

def human_detection(video_filename, output_file, downsample_factor, threshold):
    ''' This function does video processing (background subtraction) then
        does human detection on raw video and maps its output to
        background subtracted video using the input argument threshold.''' 
    global video_file
    global downsampling_factor
    video_file = video_filename
    downsampling_factor = downsample_factor

    if os.path.isfile(video_file)==False:
        raise IOError(video_file + ' not found')

    vid = video.asvideo(video_file, downsampling_factor)
    # Do Background Subtraction
    W = bs.remove_background(vid)
    human_detection_processing(vid, W, output_file, threshold)

    return 0

if __name__ == '__main__':
    args = sys.argv
    if len(args) == 1:
        # if no arguments supplied run on random video
        vid_fname = istare.random_video()
        out_fname = '/tmp/human.output'
        factor = 4
        threshold = 0.001 
        human_detection(vid_fname, out_fname, factor, threshold)
    elif len(args) == 5:
        human_detection(args[1], args[2], int(args[3]), float(args[4]))
    print __doc__
    sys.exit()
