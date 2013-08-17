'''
Connected component analysis on background subtracted video.

AUTHOR : Sagar Manohar Waghmare

How to run
python connected_components.py path_to_video_file threshold
example threshold is 0.001

'''

import video
import background_subtraction as bs
import myimage
import cv
import numpy as np
import sys
import progressbar
import istare
import pylab

colors = []
for i in range(0, 100):
    colors.append(cv.CV_RGB(np.random.rand()*255, np.random.rand()*255,
                                                 np.random.rand()*255))

def get_contour(img_array, threshold = 0.001, dilate = 0):
    ''' Does connected Component Analysis on the input image array and 
        returns the contour object.'''
    img_temp = myimage.array_image_test(img_array)
    cv_img = cv.CreateImage(cv.GetSize(img_temp), 8, 1)
    cv.CvtColor(img_temp, cv_img, cv.CV_BGR2GRAY)
    #cv_temp = cv.CloneImage(cv_img)
    cv.Threshold(cv_img, cv_img, 0, 255, cv.CV_THRESH_BINARY)

    ''' 
    cv.MorphologyEx(cv_img, cv_img, None, None, cv.CV_MOP_OPEN)
    cv.MorphologyEx(cv_img, cv_img, None, None, cv.CV_MOP_CLOSE)
    cv.Dilate(cv_img, cv_img, None, 3)
    '''
    if(dilate):
        cv.Dilate(cv_img, cv_img, None, dilate)

    total_area = float(img_array.shape[0]*img_array.shape[1])

    storage = cv.CreateMemStorage(0)
    contour = cv.FindContours(cv_img, storage, mode=cv.CV_RETR_EXTERNAL,
                                       method=cv.CV_CHAIN_APPROX_SIMPLE)
    contours = []
    count = 0
    while(contour):
        if(cv.ContourArea(contour)/total_area > threshold):
            #changed
            new_contour = cv.ApproxPoly(contour, storage,
                              cv.CV_POLY_APPROX_DP, 2, 0)
            contours.append(new_contour)
            cv.DrawContours(img_temp, new_contour, colors[count],
                                              colors[count], -1,
                        thickness = cv.CV_FILLED, lineType = 8 )
            count += 1
        contour = contour.h_next()
    return contours, myimage.image_array(img_temp), count

   
def connected_components(img_array, threshold = 0.001, dilate = 0):
    ''' Does connected Component Analysis on the input image array and
        return 2D array image with resulting blobs.'''
    img_temp = myimage.array_image_test(img_array)
    cv_img = cv.CreateImage(cv.GetSize(img_temp), 8, 1)
    if img_array.shape[2] == 1:
        cv_img = img_temp
    else:
        cv_img = cv.CreateImage(cv.GetSize(img_temp), 8, 1)
        cv.CvtColor(img_temp, cv_img, cv.CV_BGR2GRAY)
    #cv_temp = cv.CloneImage(cv_img)
    cv.Threshold(cv_img, cv_img, 0, 255, cv.CV_THRESH_BINARY)

    ''' 
    cv.MorphologyEx(cv_img, cv_img, None, None, cv.CV_MOP_OPEN)
    cv.MorphologyEx(cv_img, cv_img, None, None, cv.CV_MOP_CLOSE)
    cv.Dilate(cv_img, cv_img, None, 3)
    '''
    if(dilate):
        cv.Dilate(cv_img, cv_img, None, dilate)

    total_area = float(img_array.shape[0]*img_array.shape[1])

    storage = cv.CreateMemStorage(0)
    contour = cv.FindContours(cv_img, storage, mode=cv.CV_RETR_EXTERNAL,
                                       method=cv.CV_CHAIN_APPROX_SIMPLE)
    cv.Zero(img_temp)
    count = 0
    contours = []
    while(contour):
        if(cv.ContourArea(contour)/total_area > threshold):
            #changed
            new_contour = cv.ApproxPoly(contour, storage,
                              cv.CV_POLY_APPROX_DP, 2, 0)

            cv.DrawContours(img_temp, new_contour, colors[count], colors[count], -1, thickness = cv.CV_FILLED, lineType = 8 )
            #cv.DrawContours(img_temp, new_contour, [255, 255, 255], [255, 255, 255], -1, thickness = cv.CV_FILLED, lineType = 8 )
            contours.append(new_contour)
            count += 1
        contour = contour.h_next()

    return myimage.image_array(img_temp), count, contours
        
  
def process_video(input_video, threshold = 0.001):
    ''' Takes a background subtracted video array and percentage threshold as input
        and does connected component analysis on the video (video file).'''
 
    output_video = video.Video(frames = input_video.frames, rows = input_video.rows,
                                columns = input_video.columns, bands = 3)

    no_of_frames = input_video.frames
    pbar = progressbar.ProgressBar()
    pbar.maxval = no_of_frames

    counts = []
    total_area = float(input_video.rows * input_video.columns)
    print 'Performing Connected Component Analysis'
    contours = []
    for j in range(0, no_of_frames):
        pbar.update(j)
        output_video.V[j, ...], count, contour = connected_components(
                                           input_video.V[j, ...], threshold)
        counts.append(count)
        contours.append(contour)
    
    pbar.finish()     
    return output_video, counts, contours
    

