'''
Visualize output of Human Detection and Background Subtraction.

How To run

python visualize_human_detection.py path_to_file_boxes 
python visualize_human_detection.py /tmp/bboxes.txt 

AUTHOR : Sagar Manohar Waghmare
'''

import istare
import numpy as np
import istare.video as video
import background_subtraction as bs
import pylab
import sys
import os

   
def process_header(file_handle):
    ''' Read the Header of input file which has information
        regarding video and other parameters.'''
    line = file_handle.readline()
    line = line.strip('\n')
    if line == 'Header' :
        line = file_handle.readline()  
        fields = line.strip('\n').split(',')
        return fields[0], int(fields[1]), float(fields[2])
    else:
        raise IOError('Input file has no Header.') 

def process_file(file_handle):
    ''' Read and parse the file having frame ids and
        corresponding bounding box/es for detected human/s'''
    detected_frames = []
    total_boxes = []
    flag = False
    line = file_handle.readline() 
    while(line):
        line = line.strip('\n')
        if line == 'Data':
            flag = True
            break
        line = file_handle.readline()

    line = file_handle.readline()
    while(line and flag):
        fields = line.strip('\n').split(',')
        detected_frames.append(int(fields[0]))
        fields = fields[1::]
        count = len(fields)/4
        indx = 0
        boxes_per_frame = []
        for i in range(0, count):
            boxes_per_frame.append(eval(', '.join(fields[indx:indx+4])))
            indx += 4
        total_boxes.append(boxes_per_frame) 
        line = file_handle.readline() 
    return detected_frames, total_boxes

def draw_boxes(frame_nos, bounding_boxes, video_array):
    ''' Draw bounding boxes on numpy arrays (video) for
        visualisation. '''
    no_of_frames_det_human = len(frame_nos)

    if video_array.V.shape[3] == 1:
        color = 255
    else:
        color = [255, 0, 0]	
    for i in range(0, no_of_frames_det_human):
        frame_no = frame_nos[i]
        boxes = bounding_boxes[i]
        for box in boxes:
            top_left = []
            bottom_right = []
            top_left.append(box[0])
            top_left.append(box[1])
            bottom_right.append(box[2])
            bottom_right.append(box[3])
            video_array.V[frame_no, int(top_left[1]):int(bottom_right[1]), int(top_left[0]), :] = color
            video_array.V[frame_no, int(top_left[1]):int(bottom_right[1]), int(bottom_right[0]), :] = color
            video_array.V[frame_no, int(top_left[1]), int(top_left[0]):int(bottom_right[0]), :] = color
            video_array.V[frame_no, int(bottom_right[1]), int(top_left[0]):int(bottom_right[0]), :] = color

def draw_on_videos(raw_video, background_sub_video, file_name):
    # process the text files
    file_handle_bg = open(file_name)
    file_handle_fg = open(file_name+'r')
    detected_frames, bg_boxes = process_file(file_handle_bg)
    detected_frames, fg_boxes = process_file(file_handle_fg)

    # Draw Boxes
    draw_boxes(detected_frames, bg_boxes, background_sub_video)
    draw_boxes(detected_frames, fg_boxes, raw_video)
    return raw_video, background_sub_video

def visualize(file_name, visual = True):
    '''Visualising output of human detection stored in file_name'''
    if os.path.isfile(file_name)==False:
        raise IOError(file_name + ' not found')

    file_handle_bg = open(file_name)
    video_file, downsampling_factor, threshold = process_header(file_handle_bg)

    # Read and preprocess the video
    raw_vid = istare.get_video(video_file, downsampling_factor)
    background_sub_video = bs.remove_background(raw_video)
    raw_video, background_sub_video = draw_on_video_arrays(raw_video, background_sub_video, file_name)

    # Visualization
    while visual:
        pylab.clf()
        video.play_array([raw_video, background_sub_video])
    if visual:    
        pylab.show()

if __name__ == '__main__':
    print sys.argv
    if(len(sys.argv) != 2):
        print __doc__
        sys.exit()
    visualize(sys.argv[1])
