addpath('detector');

video_path = '/home/yao/Desktop/aladdin_repo/MindsEye/shot1/Camera_1-Shot_1-Mar_28_5_10_24_PM-Small';

detection_num = '300';
default_path = '/home/yao/Desktop/aladdin_repo/models/default';
default_list = '/home/yao/Desktop/aladdin_repo/models/threshold_default.txt';
event_path = '/home/yao/Desktop/aladdin_repo/models/models_vehicles';
event_list = '/home/yao/Desktop/aladdin_repo/models/threshold_vehicles.txt';

outcsv_path = '/home/yao/Desktop/aladdin_repo/MindsEye/output/shot1/Camera_1-Shot_1-Mar_28_5_10_24_PM-Small/csv';
draw = true;

%% detection
virat_processing(video_path, detection_num, default_path, default_list, ...
   event_path, event_list, outcsv_path, draw)


%% tracking
% cd tracking;
% final_main_tracker_slow(video_path, [outcsv_path,'/detection.csv'], [outcsv_path,'/track'], '0');


%% visualize
addpath('visualize/code');
% outimage_path = '/home/yao/Desktop/aladdin_repo/test_1/track_image';
% video_tracks(video_path, outimage_path, [outcsv_path,'/track'], [outcsv_path,'/idmap.txt']);

outimage_path = '/home/yao/Desktop/aladdin_repo/MindsEye/output/shot1/Camera_1-Shot_1-Mar_28_5_10_24_PM-Small/det_img';
bbox_path = [outcsv_path, '/detection.csv'];
idmap_path = [outcsv_path, '/idmap.txt'];
% bbox_path = '/home/yao/Desktop/aladdin_repo/MindsEye/output/shot1/Camera_1-Shot_1-Mar_28_5_10_24_PM-Small/csv/detection.csv';
% idmap_path = '/home/yao/Desktop/aladdin_repo/MindsEye/output/shot1/Camera_1-Shot_1-Mar_28_5_10_24_PM-Small/csv/idmap.txt';

% video_detection(video_path, outimage_path, bbox_path, idmap_path);

% video_detection(video_path, output_path, bbox_path, idmap_path)
% video_path: path to your extracted video frames
% outimage_path: path to output image directory
% bbox_path: path to bounding box csv file
% idmap_path: path to id map file





