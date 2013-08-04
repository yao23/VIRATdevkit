function track_virat_all

% Purpose : Track persons and vehicles with unique ID and output attributes in TML
% Authors : Yao Li
% To do : adjust tracking output size from 1721 x 973 to 1920 x 1080, or
% sth as Chenliang did to obtain better tracking results


% video_total_path = '/home/yao/Desktop/VIRAT_video_cut4/';

output_detect_track_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas';
% outcsv_total_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/VIRAT/';
% outimage_total_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/';

% dataset = 'VIRAT';
dataset = 'TSU';
switch dataset
    case 'VIRAT'
        video_id_offset = 0;
        video_total_path = '/home/yao/Desktop/VIRAT_video_cut3/';
        outcsv_total_path = [output_detect_track_path '/VIRAT/'];
%         outimage_total_path = [output_detect_track_path '/VIRAT/track_image'];
    case 'PSU'
        video_id_offset = 70;
        video_total_path = '/home/yao/Projects/object_detection/dataset/PSU_video_cut/';
        outcsv_total_path = [output_detect_track_path '/PSU/'];
%         outimage_total_path = [output_detect_track_path '/PSU/track_image'];
    case 'TSU_simple'
        video_id_offset = 75; % TSU complete dataset, 5 sets
        video_total_path = '/home/yao/Desktop/TSU_Experiments/X_JPG_FORMAT';
        outcsv_total_path = [output_detect_track_path '/TSU_Experiments/'];
%         outimage_total_path = [output_detect_track_path '/TSU_Experiments/track_image'];
    case 'TSU'
        video_id_offset = 80; % TSU complete dataset, 20 sets
        video_total_path = '/home/yao/Projects/object_detection/dataset/TSU/';
%         outcsv_total_path = [output_detect_track_path '/TSU/'];
        outcsv_total_path = [output_detect_track_path '/TSU_complete/'];
%         outimage_total_path = [output_detect_track_path '/TSU/track_image'];
    otherwise
        disp('unknown dataset');
end                       
        
dir_list = dir(video_total_path);
dir_num = length(dir_list);

for i = 3:dir_num
    %%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/VIRAT_S_050202_08_001410_001494/';
    video_path = [video_total_path dir_list(i).name];
    
    %%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/VIRAT_S_050202_08_001410_001494/csv';
    %%% outcsv_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/TSU_Experiments/Vehicle_flee_1/csv';
    outcsv_path = [outcsv_total_path dir_list(i).name '/csv'];
    %%% outimage_path = '/home/yao/Projects/object_detection/tools/VIRATdevkit/tracking_results/VIRAT/VIRAT_S_050202_08_001410_001494/track_image';
%     outimage_path = [outimage_total_path dir_list(i).name '/track_image'];
    outimage_path = [outcsv_total_path dir_list(i).name '/track_image'];
    draw = false;

    process_detect_track(video_path, outcsv_path, outimage_path, draw, i-2+video_id_offset);
    
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
cd /home/yao/Projects/object_detection/tools/VIRATdevkit/tracking;
final_main_tracker_slow(video_path, [outcsv_path,'/detection.csv'], [outcsv_path,'/track'], '0');

%% visualize
cd /home/yao/Projects/object_detection/tools/VIRATdevkit/visualize/code;
if ~exist(outimage_path, 'dir')
    mkdir(outimage_path);
end

video_tracks(video_path, outimage_path, outtrack_path, [outcsv_path,'/idmap.txt'],...
             outcsv_path, video_id);

cd /home/yao/Projects/object_detection/tools/VIRATdevkit/;

end