%clear all; close all;clc;
% Input filename text file - it contains all the videofile names
vidlistfilename = 'countryroad1.txt';
% Directory where this file is located
vidlistdir = '/big2t/DARPA_DATA/C-D2B/Country_Road_1';

% Video directory
viddir = '/big2t/DARPA_DATA/C-D2B/Country_Road_1';

% Bounding Box Data - where your detection csv files are written
bboxdirectory = '/big2t/istareproject/object-tracking/evaluations_tracker/detections';

% Outputdata directory - where your tracked csv files will be written
outdatadir = '/big2t/istareproject/object-tracking/evaluations_tracker/tracks';

% Directory of frames - in original resolution for optical flow and visuals
framedir = '/big2t/istareproject/object-tracking/evaluations_tracker/orgframes';

% Directory for placing background subtraction data
sildir = '/big2t/istareproject/object-tracking/evaluations_tracker/bgdata';

% To break the video into parts
vidpartdir = '/big2t/istareproject/object-tracking/evaluations_tracker/videoparts';

% Detection specific details
% Input frame directory for cuda detections
inpframedir = '/big2t/istareproject/object-tracking/evaluations_tracker/det_input_frames';
% Output frame directory with overlaid detection
outframedir = '/big2t/istareproject/object-tracking/evaluations_tracker/detected_frames';

final_main_tracker(vidlistfilename,vidlistdir,viddir,vidpartdir,bboxdirectory,...
    outdatadir,framedir,inpframedir,outframedir,sildir);
