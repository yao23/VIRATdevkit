function psu_attribute
%%% video_path = '/home/yao/Desktop/VIRAT_video_cut3/';
video_path = '/home/yao/Projects/object_detection/dataset/PSU_video_cut/';

%%% VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/VIRAT/';
%%  WalkUpDealTake#1 is located in /home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/PSU_Backup
%   The content is divided into two parts, WalkUpDealTake#1_Scene3.1 and
%   WalkUpDealTake#1_Scene3.2, both of them are in the VIRAT_output_dir

VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/PSU/';
%%% VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/';
%%% VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test/VIRAT/';
dir_list = dir(VIRAT_output_dir);
dir_num = length(dir_list);

% process bbox information folder by folder 
% 1 for current directory, 2 for parent directory
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

function virat_height_color(video_id, im, bbox_info, line_id, attribute_path)

frame_id = bbox_info(line_id, 1);
frame_info = bbox_info(line_id, 2:end);

year = 2010;

[month, day, hour, minute, second, longitude, latitude] = time_space(video_id, frame_id);

person_pos = object_position(frame_info, 'person');
bus_pos = object_position(frame_info, 'bus');
car_pos = object_position(frame_info, 'car');

fid = fopen(attribute_path, 'a');
fprintf(fid, '%s', '<data ref="SENSOR_NAME">');
fprintf(fid, '%d,', frame_id);
fprintf(fid,'%04d-%02d-%02d %02d:%02d:%02d', year, month, day, hour, minute, second);

if ~isempty(person_pos)
    person_height(person_pos, fid, longitude, latitude);
end

if ~isempty(bus_pos)
    vehicle_color(bus_pos, fid, im, 'bus', longitude, latitude);
end

if ~isempty(car_pos)
    vehicle_color(car_pos, fid, im, 'car', longitude, latitude);
end

fprintf(fid, '%s\n', '</data>');
fclose(fid);

end

function [month, day, hour, minute, second, longitude, latitude] = time_space(video_id, frame_id)

if video_id < 6
    longitude = 47.285;
    latitude = 32.507;
    month = 3;
    day = video_id - 1 + 16;
    hour = 13;
    minute = 23 + video_id;
    second = 16 + frame_id;
    [month, day, hour, minute, second] = time_process(month, day, hour, minute, second);
elseif video_id < 42
    longitude = 45.827;
    latitude = 33.507;
    month = 4;
    day = video_id - 5;
    hour = 10;
    minute = 13 + (video_id - 5);
    second = 15 + frame_id;
    [month, day, hour, minute, second] = time_process(month, day, hour, minute, second);
else
    longitude = 48.276;
    latitude = 33.505;
    month = 5;
    day = video_id - 41;
    hour = 15;
    minute = 33 + (video_id - 41);
    second = 14 + frame_id;
    [month, day, hour, minute, second] = time_process(month, day, hour, minute, second);
end

end

function [month, day, hour, minute, second] = time_process(month, day, hour, minute, second)

if second >= 60
   minute = minute + ceil(second/60);
   second = mod(second, 60);
end

if minute >= 60
   hour = hour + ceil(minute/60);
   minute = mod(minute, 60);
end

if hour >= 24
   day = day + ceil(hour/24);
   hour = mod(hour, 24);
end

if day == 0
   day = 1;
end

if month == 4
    mod_day = 30;
else 
    mod_day = 31;
end

if day > mod_day
   month = month + ceil(day/mod_day);
   day = mod(day, mod_day);
end

end

function person_height(person_pos, fid, longitude, latitude)

person_class_ID = 1;
obj_num = size(person_pos, 1);
height_types = cell(1, obj_num);
 
for i = 1:obj_num
    height = person_pos(i,4) - person_pos(i,2);
    if height >= 150
        height_types{1, i} = 'tall';
    elseif height >= 100
        height_types{1, i} = 'medium';
    else
        height_types{1, i} = 'short';
    end
    [longitude_offset, latitude_offset] = space_process(person_pos(i,1:4));
    fprintf(fid, ',');
    fprintf(fid,'%d,%d,%.2f,%.2f,%.2f,%.2f,%s %.3f,%s %.3f,%s', person_class_ID, i, person_pos(i,1), person_pos(i,2), person_pos(i,3), person_pos(i,4), 'E', longitude+longitude_offset, 'N', latitude+latitude_offset, height_types{1, i});
end

end

function vehicle_color(veh_pos, fid, im, vehicle_class, longitude, latitude)

if strcmp(vehicle_class, 'bus')
   veh_class_ID = 2;
else 
   veh_class_ID = 3;
end

img = imread(im);
 
obj_num = size(veh_pos, 1);
color_types = cell(1, obj_num);
 
for i = 1:obj_num
    x1 = int64(veh_pos(i,1));
    y1 = int64(veh_pos(i,2));
    x2 = int64(veh_pos(i,3));
    y2 = int64(veh_pos(i,4));
    vehs_crop = img(y1:y2, x1:x2, :);
    color_types{1, i} = rgbhist(vehs_crop);
    [longitude_offset, latitude_offset] = space_process(veh_pos(i,1:4));
    fprintf(fid, ',');
    fprintf(fid,'%d,%d,%.2f,%.2f,%.2f,%.2f,%s %.3f,%s %.3f,%s', veh_class_ID, i, veh_pos(i,1), veh_pos(i,2), veh_pos(i,3), veh_pos(i,4), 'E', longitude+longitude_offset, 'N', latitude+latitude_offset, color_types{1, i});
end
 
end

function [longitude_offset, latitude_offset] = space_process(position)

central_x = 960;
central_y = 540;

longitude_offset = (central_x - (position(1,3) + position(1,1))/2)/100;
latitude_offset = (central_y - (position(1,4) + position(1,2))/2)/100;

end

function obj_pos = object_position(frame_info, object_class)

switch object_class
   case 'person'
      object_class_ID = 1;
   case 'bus'
      object_class_ID = 2;
   case 'car'
      object_class_ID = 3;     
   otherwise
      object_class_ID = 4;
end

obj_pos_tmp = (reshape(frame_info, 5, []))';

obj_pos_label = obj_pos_tmp(:,1)==object_class_ID;

obj_color_matrix = obj_pos_tmp(obj_pos_label,:);

obj_pos = obj_color_matrix(:,2:5);

end

function color_type = rgbhist(I)
 
if (size(I, 3) ~= 3)
   error('rgbhist:numberOfSamples', 'Input image must be RGB.')
end
 
nBins = 256;
 
rHist = imhist(I(:,:,1), nBins);
gHist = imhist(I(:,:,2), nBins);
bHist = imhist(I(:,:,3), nBins);
 
[r_vote, r] = max(rHist);
[g_vote, g] = max(gHist);
[b_vote, b] = max(bHist);

if (g >= 200) && (b >= 200)
    color_type = 'white';
elseif r >= 117
   color_type = 'red';
else
   color_type = 'black/deep';
end
 
end


