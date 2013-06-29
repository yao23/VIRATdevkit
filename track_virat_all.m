function track_virat_all

% Purpose : Track persons and vehicles with unique ID and output attributes in TML
% Authors : Yao Li
% To do : adjust tracking output size from 1721 x 973 to 1920 x 1080, or
% sth as Chenliang did to obtain better tracking results

% video_total_path = '/home/yao/Desktop/VIRAT_video_cut3/';
video_total_path = '/home/yao/Desktop/VIRAT_video_cut4/';
dir_list = dir(video_total_path);
dir_num = length(dir_list);

outcsv_total_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/VIRAT/';
outimage_total_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/';

for i = 3:dir_num
    %%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/VIRAT_S_050202_08_001410_001494/';
    video_path = [video_total_path dir_list(i).name];
    
    %%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/VIRAT_S_050202_08_001410_001494/csv';
    %%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Vehicle_flee_1/csv';
    outcsv_path = [outcsv_total_path dir_list(i).name '/csv'];
    %%% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/VIRAT_S_050202_08_001410_001494/track_image';
    outimage_path = [outimage_total_path dir_list(i).name '/track_image'];
    draw = false;

    process_detect_track(video_path, outcsv_path, outimage_path, draw, i-2);
    
end

end

function process_detect_track(video_path, outcsv_path, outimage_path, draw, video_id)

outtrack_path = [outcsv_path,'/track'];
if ~exist(outtrack_path, 'dir')
    mkdir(outtrack_path);
end

%% detection

% detection_num is used in detection step and track number will be the same
% detection_num = '3';
% default_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/default';
% default_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_default.txt';
% event_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/models_vehicles';
% event_list = '/home/yao/Projects/object_detection/tools/VIRATdevkit/models_pas/threshold_vehicles.txt';

% virat_processing(video_path, detection_num, default_path, default_list, ...
%   event_path, event_list, outcsv_path, draw)


%% tracking
% cd /home/yao/Projects/object_detection/tools/VIRATdevkit/tracking;
% final_main_tracker_slow(video_path, [outcsv_path,'/detection.csv'], [outcsv_path,'/track'], '0');

%% visualize
cd /home/yao/Projects/object_detection/tools/VIRATdevkit/visualize/code;
if ~exist(outimage_path, 'dir')
    mkdir(outimage_path);
end

video_tracks(video_path, outimage_path, outtrack_path, [outcsv_path,'/idmap.txt'],...
             outcsv_path, video_id);

cd /home/yao/Projects/object_detection/tools/VIRATdevkit/;

end