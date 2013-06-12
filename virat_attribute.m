function virat_attribute
video_path = '/home/yao/Desktop/VIRAT_video_cut3/';
%%% VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/VIRAT/';
VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/';
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

year = 2010;

if video_id < 6
    longitude = 47.285;
    latitude = 32.507;
    month = 3;
    day = video_id - 1 + 16;
elseif video_id < 42
    longitude = 45.827;
    latitude = 33.507;
    month = 4;
    day = mod((video_id - 5), 30);
    if day == 0
        day = 1;
    end
else
    longitude = 48.276;
    latitude = 33.505;
    month = 5;
    day = video_id - 41;
end


frame_id = bbox_info(line_id, 1);
frame_info = bbox_info(line_id, 2:end);

person_pos = object_position(frame_info, 'person');
bus_pos = object_position(frame_info, 'bus');
car_pos = object_position(frame_info, 'car');

fid = fopen(attribute_path, 'a');
fprintf(fid, '%s', '<data ref="SENSOR_NAME">');
fprintf(fid,'%02d/%02d/%04d,%s %.3f,%s %.3f', month, day, year, 'E', longitude, 'N', latitude);
fprintf(fid, '%s\n', '</data>');
fprintf(fid, '%s', '<data ref="SENSOR_NAME">');
fprintf(fid, '%d', frame_id);

if ~isempty(person_pos)
    person_height(person_pos, fid);
end

if ~isempty(bus_pos)
    vehicle_color(bus_pos, fid, im, 'bus');
end

if ~isempty(car_pos)
    vehicle_color(car_pos, fid, im, 'car');
end

fprintf(fid, '%s\n', '</data>');
fclose(fid);

end

function person_height(person_pos, fid)

person_class_ID = 1;
obj_num = size(person_pos, 1);
height_types = cell(1, obj_num);
 
for i = 1:obj_num
    height = person_pos(i,4) - person_pos(i,2);
    if height >= 50
        height_types{1, i} = 'tall';
    elseif height >= 30
        height_types{1, i} = 'medium';
    else
        height_types{1, i} = 'short';

    end
    fprintf(fid, ',');
    fprintf(fid,'%d,%.2f,%.2f,%.2f,%.2f,%s', person_class_ID, person_pos(i,1), person_pos(i,2), person_pos(i,3), person_pos(i,4), height_types{1, i});
end

end

function vehicle_color(veh_pos, fid, im, vehicle_class)

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
    fprintf(fid, ',');
    fprintf(fid,'%d,%.2f,%.2f,%.2f,%.2f,%s', veh_class_ID, veh_pos(i,1), veh_pos(i,2), veh_pos(i,3), veh_pos(i,4), color_types{1, i});
end
 
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


