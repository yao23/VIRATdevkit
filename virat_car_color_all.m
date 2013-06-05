function color_types = virat_car_color_all
video_path = '/home/yao/Desktop/VIRAT_video_cut3/';
%%% VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_pas/VIRAT/';
VIRAT_output_dir = '/home/yao/Projects/object_detection/tools/VIRATdevkit/output/detection_test_all/VIRAT/';
dir_list = dir(VIRAT_output_dir);
dir_num = length(dir_list);
obj_num = 50;
color_types = zeros(dir_num-2, obj_num);

% process bbox information folder by folder 
% 1 for current directory, 2 for parent directory
for i = 3:dir_num
   % read bounding box information 
   bbox_info = csvread([VIRAT_output_dir dir_list(i).name '/csv/detection.csv']);
   img_num = length(bbox_info);
   % process bbox information line by line 
   for j=1:img_num
      frame_id = bbox_info(j,1);
      %%% bbox_frame = bbox_info(j, 2:end);
      im = sprintf('%s/%06d.jpg', [video_path dir_list(i).name], frame_id);
      color_types(j,:) = virat_car_color(im, bbox_info, j);
      %%% virat_videobbox(im, frame_id, [output_det_img_path dir_list(i).name], bbox_frame, models);
   end
end
end

function color_types = virat_car_color(im, bbox_info, line_id)

bbox_frame = bbox_info(:, 2:end);
frame_test = bbox_frame(line_id, :);
car_pos = object_position(frame_test, 'car');

img = imread(im);

obj_num = length(car_pos);
hist_info = zeros(obj_num, 256*3);
color_info = zeros(obj_num, 3);
color_types = zeros(1, obj_num);

for i = 1:obj_num
    x1 = int64(car_pos(i,1));
    y1 = int64(car_pos(i,2));
    x2 = int64(car_pos(i,3));
    y2 = int64(car_pos(i,4));
    cars_crop = img(y1:y2, x1:x2, :);  
    [hist_info(i, :), color_info(i, :), color_types(1, i)] = rgbhist(cars_crop);
end

k = 5;
color_class = kmeans(hist_info, k);
obj_num_tmp = 1:obj_num;
color_class_tmp = cat(2, obj_num_tmp', color_class);

color_dis = zeros(k, obj_num);

for i = 1:k
    color_dis_label = color_class(:,1)==i;
    color_car_num = sum(color_dis_label);
    color_dis(i, 1:color_car_num) = color_class_tmp(color_dis_label,1)';
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

function [hist_info, color, color_type] = rgbhist(I)

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
color = [r g b];

if (g >= 200) && (b >= 200)
   color_type = 'white vehicle';
elseif r >= 117
   color_type = 'red vehicle';
else
   color_type = 'black/deep vehicle';
end

hist_info = cat(2, rHist', gHist', bHist');

% figure
% subplot(1,2,1);imshow(I)
% title(color_type);
% 
% subplot(1,2,2);
% 
% h(1) = stem(1:256, rHist); hold on
% h(2) = stem(1:256 + 1/3, gHist);
% h(3) = stem(1:256 + 2/3, bHist);
% hold off
% 
% set(h, 'marker', 'none')
% set(h(1), 'color', [1 0 0])
% set(h(2), 'color', [0 1 0])
% set(h(3), 'color', [0 0 1])
% 
% axis square 
end



