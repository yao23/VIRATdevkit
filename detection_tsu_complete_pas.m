function detection_tsu_complete_pas
% Purpose : Detect persons and vehicles and generate bbox in csv file and image in det_img
% Authors : Yao Li
% To do : Scenario-18-Sun-79, 000073.jpg (Image0072.bmp) is corrupted so
% use 000072.jpg (Image0071.bmp) to replace  

video_total_path = '/home/yao/Projects/object_detection/dataset/TSU/';
dir_list = dir(video_total_path);
dir_num = length(dir_list);

outcsv_total_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_complete/';
outimage_total_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/TSU_complete/';

for i = 3:dir_num
    %%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/VIRAT_S_050202_08_001410_001494/';
    video_path = [video_total_path dir_list(i).name];
    
    %%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/VIRAT_S_050202_08_001410_001494/csv';
    %%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Vehicle_flee_1/csv';
    outcsv_path = [outcsv_total_path dir_list(i).name '/csv'];
    %%% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/VIRAT_S_050202_08_001410_001494/track_image';
    outimage_path = [outimage_total_path dir_list(i).name '/track_image'];
    draw = false;

    process_detect_track(video_path, outcsv_path, outimage_path, draw);
    
end

end

function process_detect_track(video_path, outcsv_path, outimage_path, draw)
%   addpath('detector');

%video_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT/Group_activity';

%detection_num = '676';
dir_list = dir(video_path);
dir_num = length(dir_list);
detection_num = num2str(dir_num-2);
default_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/default';
default_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_default.txt';
event_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/models_vehicles';
event_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_vehicles.txt';

%outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Group_activity/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/example/csv';
%draw = false;

if ~exist(outcsv_path, 'dir')
    mkdir(outcsv_path);
end

%% detection
virat_processing(video_path, detection_num, default_path, default_list, ...
   event_path, event_list, outcsv_path, draw)

%% visualize
addpath('visualize/code');
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/track_image';
% if ~exist(outimage_path, 'dir')
%    mkdir(outimage_path);
% end
% video_tracks(video_path, outimage_path, [outcsv_path,'/track'], [outcsv_path,'/idmap.txt']);

%outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Group_activity/det_img';
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/example/det_img';
bbox_path = [outcsv_path, '/detection.csv'];
idmap_path = [outcsv_path, '/idmap.txt'];

if ~exist(outimage_path, 'dir')
    mkdir(outimage_path);
end

video_detection(video_path, outimage_path, bbox_path, idmap_path);

% bbox_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/csv/detection.csv';
% idmap_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection/VIRAT_S_000001/csv/idmap.txt';

% video_detection(video_path, output_path, bbox_path, idmap_path)
% video_path: path to your extracted video frames
% outimage_path: path to output image directory
% bbox_path: path to bounding box csv file
% idmap_path: path to id map file

end



