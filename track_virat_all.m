funcition track_virat_all

% Purpose : Track persons and vehicles with unique ID and output attributes in TML
% Authors : Yao Li
% To do : adjust tracking output size from 1721 x 973 to 1920 x 1080, or
% sth as Chenliang did to obtain better tracking results

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

dir_list = dir(video_path);
dir_num = length(dir_list);

for i = 3:dir_num
   % vehicle color information
   attribute_path = [VIRAT_output_dir dir_list(i).name '/csv/attribute.csv'];
   if exist(attribute_path, 'file')
       delete(attribute_path);
   end
   % read bounding box information 
   bbox_info = csvread([VIRAT_output_dir dir_list(i).name '/csv/detection.csv']);
   img_num = size(bbox_info, 1);
   % process bbox information line by line 
   for j=1:img_num
      if bbox_info(j,2) == 0
         continue
      else
          frame_id = bbox_info(j,1);
          im = sprintf('%s/%06d.jpg', [video_path dir_list(i).name], frame_id);
          virat_height_color(i-2, im, bbox_info, j, attribute_path);
      end
   end
end

end

function process_detect_track

outtrack_path = [outcsv_path,'/track'];
if ~exist(outtrack_path, 'dir')
    mkdir(outtrack_path);
end

%% detection
% virat_processing(video_path, detection_num, default_path, default_list, ...
%   event_path, event_list, outcsv_path, draw)
% aladdin_processing_fix(video_path, detection_num, default_path, default_list, ...
%    event_path, event_list, outcsv_path, draw)


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

video_tracks(video_path, outimage_path, outtrack_path, [outcsv_path,'/idmap.txt'],...
             outcsv_path, video_id);

cd /home/yao/Projects/object_detection/tools/VIRATdevkit/;

end