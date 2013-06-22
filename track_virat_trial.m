% Purpose : Track persons and vehicles with unique ID and output attributes in TML
% Authors : Yao Li
% To do : None

%%% video_path = '/home/yao/Desktop/aladdin_repo/tracking_results/VIRAT_Video_Dataset/VIRAT_S_000001/video';
%%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/';
%%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/VIRAT_S_050202_08_001410_001494/';
video_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT/Vehicle_flee_1'; 

% detection_num is used in detection step and track number will be the same
detection_num = '3';
default_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/default';
default_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_default.txt';
event_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/models_vehicles';
event_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_vehicles.txt';

%%% outcsv_path = '/home/yao/Desktop/aladdin_repo/tracking_results/VIRAT_Video_Dataset/VIRAT_S_000001/csv';
%%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/VIRAT_S_050202_08_001410_001494/csv';
outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Vehicle_flee_1/csv';
draw = false;

outtrack_path = [outcsv_path,'/track'];
if ~exist(outtrack_path, 'dir')
    mkdir(outtrack_path);
end

%% detection
% virat_processing(video_path, detection_num, default_path, default_list, ...
%    event_path, event_list, outcsv_path, draw)
% aladdin_processing_fix(video_path, detection_num, default_path, default_list, ...
% event_path, event_list, outcsv_path, draw)


%% tracking
% cd /home/yao/Projects/object_detection/tools/VIRATdevkit/tracking;
% final_main_tracker_slow(video_path, [outcsv_path,'/detection.csv'], [outcsv_path,'/track'], '0');

%% visualize
cd /home/yao/Projects/object_detection/tools/VIRATdevkit/visualize/code;
%%% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/VIRAT_S_050202_08_001410_001494/track_image';
outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/TSU/Vehicle_flee_1/track_image'; 
if ~exist(outimage_path, 'dir')
    mkdir(outimage_path);
end

video_tracks(video_path, outimage_path, outtrack_path, [outcsv_path,'/idmap.txt'], outcsv_path, video_id);

cd /home/yao/Projects/object_detection/tools/VIRATdevkit/;