% Purpose : Track persons and vehicles with unique ID and output attributes in TML
% Authors : Yao Li
% To do : 1. in video_tracks, x and y for cropping image to call function
%         rgbhist(I). 2. global unique ID (figure out object_num, namely 
%         tracks{i}.num, test_all example, car 18, person 5.  3. fixed height/color attribute
%         for each tracked objects (highlighted in csv file, same y1 and
%         y2)

% video_path = '/home/yao/Desktop/aladdin_repo/tracking_results/VIRAT_Video_Dataset/VIRAT_S_000001/video';
% video_path = '/home/yao/Desktop/VIRAT_video_cut3/VIRAT_S_000001/'; video_id = 5;
% video_path = '/home/yao/Desktop/VIRAT_video_cut5/VIRAT_S_000001/'; video_id = 5;
% video_path = '/home/yao/Desktop/VIRAT_video_cut6/VIRAT_S_000001/'; video_id = 5;
%%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/';
%%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/VIRAT_S_050202_08_001410_001494/'; video_id = 5;
% video_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT/Group_activity'; video_id = 76;
% video_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT/Heavy Box Pick Up'; video_id = 77;
% video_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT/Loading&Unloading_exp'; video_id = 78;
video_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT/Packages Pick Up'; video_id = 79;
%%% video_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT/Vehicle_flee_1'; video_id = 80;
% video_path = '/home/yao/Projects/object_detection/dataset/PSU_video_cut/ArrestAtMarket_Take#1/left_subclip'; video_id = 71;
% video_path = '/home/yao/Projects/object_detection/dataset/PSU_video_cut/CheckingPrisonerInTake#3/left_subclip'; video_id = 72;
% video_path = '/home/yao/Projects/object_detection/dataset/PSU_video_cut/JailBreakTake#3/left_subclip'; video_id = 73;
% video_path = '/home/yao/Projects/object_detection/dataset/PSU_video_cut/WalkUpDealTake#1/Scene3.1/left_subclip'; video_id = 74;
% video_path = '/home/yao/Projects/object_detection/dataset/PSU_video_cut/WalkUpDealTake#1/Scene3.2/left_subclip'; video_id = 75;

% detection_num is used in detection step and track number will be the same
% detection_num = '30';
detection_num = '100';
default_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/default';
default_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_default.txt';
event_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/models_vehicles';
event_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_vehicles.txt';

%outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/VIRAT/VIRAT_S_000001/csv';
%outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test/VIRAT5/VIRAT_S_000001/csv';
%outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/VIRAT6/VIRAT_S_000001/csv';
%outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/VIRAT_S_000001/csv';
% outcsv_path = '/home/yao/Desktop/aladdin_repo/tracking_results/VIRAT_Video_Dataset/VIRAT_S_000001/csv';
%%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/VIRAT_S_050202_08_001410_001494/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Group_activity/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Heavy Box Pick Up/csv';
%outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Loading&Unloading_exp/csv';
outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Packages Pick Up/csv';
%%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Vehicle_flee_1/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/PSU/ArrestAtMarket_Take#1/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/PSU/CheckingPrisonerInTake#3/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/PSU/JailBreakTake#3/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/PSU/WalkUpDealTake#1_Scene3.1/csv';
% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/PSU/WalkUpDealTake#1_Scene3.2/csv';
draw = false;

if ~exist(outcsv_path, 'dir')
    mkdir(outcsv_path);
end

outtrack_path = [outcsv_path,'/track'];
if ~exist(outtrack_path, 'dir')
    mkdir(outtrack_path);
end

%% detection
% virat_processing(video_path, detection_num, default_path, default_list, ...
%   event_path, event_list, outcsv_path, draw);
% aladdin_processing_fix(video_path, detection_num, default_path, default_list, ...
% event_path, event_list, outcsv_path, draw)


%% tracking
cd /home/yao/Projects/object_detection/tools/VIRATdevkit/tracking;
final_main_tracker_slow(video_path, [outcsv_path,'/detection.csv'], [outcsv_path,'/track'], '1');

%% visualize
cd /home/yao/Projects/object_detection/tools/VIRATdevkit/visualize/code;
%outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/VIRAT_S_000001/track_image';
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test/VIRAT5//VIRAT_S_000001/track_image';
%outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test/VIRAT6/VIRAT_S_000001/track_image';
%%% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/VIRAT_S_050202_08_001410_001494/track_image';
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/TSU/Group_activity/track_image'; 
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/TSU/Heavy Box Pick Up/track_image'; 
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/TSU/Loading&Unloading_exp/track_image'; 
outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/TSU/Packages Pick Up/track_image'; 
%%% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/TSU/Vehicle_flee_1/track_image'; 
%outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/PSU/ArrestAtMarket_Take#1/track_image';
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/PSU/CheckingPrisonerInTake#3/track_image';
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/PSU/JailBreakTake#3/track_image';
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/PSU/WalkUpDealTake#1_Scene3.1/track_image';
% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/PSU/WalkUpDealTake#1_Scene3.2/track_image';
if ~exist(outimage_path, 'dir')
    mkdir(outimage_path);
end

video_tracks(video_path, outimage_path, outtrack_path, [outcsv_path,'/idmap.txt'], outcsv_path, video_id);

cd /home/yao/Projects/object_detection/tools/VIRATdevkit/;