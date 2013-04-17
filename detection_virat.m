% addpath('detector');

video_path = '/home/yao/Desktop/VIRAT_video_cut3/VIRAT_S_000001';

detection_num = '300';
default_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models/default';
default_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models/threshold_default.txt';
event_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models/models_vehicles';
event_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models/threshold_vehicles.txt';

outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/csv';
draw = true;

if ~exist(outcsv_path, 'dir')
    mkdir(outcsv_path);
end

%% detection
virat_processing(video_path, detection_num, default_path, default_list, ...
   event_path, event_list, outcsv_path, draw)


%% tracking
% cd tracking;
% final_main_tracker_slow(video_path, [outcsv_path,'/detection.csv'], [outcsv_path,'/track'], '0');


%% visualize
addpath('visualize/code');
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/track_image';
% if ~exist(outimage_path, 'dir')
%    mkdir(outimage_path);
% end
% video_tracks(video_path, outimage_path, [outcsv_path,'/track'], [outcsv_path,'/idmap.txt']);

outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/det_img';
bbox_path = [outcsv_path, '/detection.csv'];
idmap_path = [outcsv_path, '/idmap.txt'];
% bbox_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/csv/detection.csv';
% idmap_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/csv/idmap.txt';

if ~exist(outimage_path, 'dir')
    mkdir(outimage_path);
end

% video_detection(video_path, outimage_path, bbox_path, idmap_path);

% video_detection(video_path, output_path, bbox_path, idmap_path)
% video_path: path to your extracted video frames
% outimage_path: path to output image directory
% bbox_path: path to bounding box csv file
% idmap_path: path to id map file





