function virat_processing(video_path, detection_num, default_path, default_list, ...
   event_path, event_list, outcsv_path, draw)
% video_path: path to your extracted frames from the video
% detection_num: number of detection frames per video
% default_path, event_path: path to your trained detection models
% default_list, event_list: list contains the models and thresholds
% outcsv_path: path to save the bounding box csv file and id map
% draw: true/false

% video_path = '../test/HVC576709';
% detection_num = '30';
% default_path = '../models/default';
% default_list = '../models/threshold_default.txt';
% event_path = '../models/models_E028';
% event_list = '../models/threshold_E028.txt';
% outcsv_path = '../test/HVC576709_csv_detection_num';
% draw = false;

detection_num = str2num(detection_num);

if ~exist(outcsv_path, 'dir')
    mkdir(outcsv_path);
end

%% Read Models and Thresholds
models_num = 0;
models = [];
if default_path(end) == '/'
    default_path = default_path(1:end-1);
end
if event_path(end) == '/'
    event_path = event_path(1:end-1);
end
% default models
default_fid = fopen(default_list, 'r');
default_file = textscan(default_fid, '%s %d\n');
default_names = default_file{1,1};
default_threshs = default_file{1,2};
default_num = length(default_names);
for i=1:default_num
    models_num = models_num + 1;
    models{models_num}.model = importdata([default_path, '/', default_names{i,1}]);
    if default_threshs(i,1) == 99
        models{models_num}.thresh = models{models_num}.model.thresh;
    else
        models{models_num}.thresh = default_threshs(i,1);
    end
end
% event models
event_fid = fopen(event_list, 'r');
event_file = textscan(event_fid, '%s %d\n');
event_names = event_file{1,1};
event_threshs = event_file{1,2};
event_num = length(event_names);
for i=1:event_num
    models_num = models_num + 1;
    models{models_num}.model = importdata([event_path, '/', event_names{i,1}]);
    if event_threshs(i,1) == 99
        models{models_num}.thresh = models{models_num}.model.thresh;
    else
        models{models_num}.thresh = event_threshs(i,1);
    end
end
% write down id map
idmap_fid = fopen([outcsv_path, '/idmap.txt'], 'w');
for i=1:models_num
    fprintf(idmap_fid, '%d %s %f\n', i, models{i}.model.class, models{i}.thresh);
end
fclose(idmap_fid);

%% Detection
bbox_path = [outcsv_path, '/detection_tmp.csv'];
if exist(bbox_path, 'file')
    delete(bbox_path);
end
video_dir = dir(video_path);
frame_num = length(video_dir)-2;
% how many detections in total
if detection_num > frame_num
    detection_num = frame_num
end

% detection_num = floor((frame_num - 1)/step) + 1;
step = floor((frame_num-1)/(detection_num-1));
% matlabpool;
for i=1:detection_num
    frame_id = (i-1)*step + 1;
%     frame_path = sprintf('%s/%06d.bmp', video_path, frame_id);
    frame_path = sprintf('%s/%06d.jpg', video_path, frame_id);
%     frame_path = sprintf('%s/%06d.JPG', video_path, frame_id);
    im = imread(frame_path);
    bbox_frame = [];
    for j=1:models_num
        bbox_model = [];
        bbox_model = process(im, models{j}.model, models{j}.thresh);
        if ~isempty(bbox_model)
            bbox_model = bbox_model(:,1:4);
            bbox_id = [];
            bbox_id = ones(size(bbox_model, 1), 1)*j;
            bbox_model = horzcat(bbox_id, bbox_model);
            bbox_model = bbox_model';
            bbox_model = reshape(bbox_model, 1, []);
            bbox_frame = horzcat(bbox_frame, bbox_model);
        end
    end
    if isempty(bbox_frame)
        dlmwrite(bbox_path, [frame_id,0,0,0,0,0], '-append', 'delimiter', ',');
    else
        dlmwrite(bbox_path, [frame_id,bbox_frame], '-append', 'delimiter', ',');
    end
    
    % plot detection image
    if draw == true
        virat_videobbox(im, frame_id, outcsv_path, bbox_frame, models);
    end
end
% matlabpool close;

% sort results
bbox_result = csvread(bbox_path);
[~, bbox_ix] = sort(bbox_result(:,1));
bbox_result = bbox_result(bbox_ix,:);
bbox_path = [outcsv_path, '/detection.csv'];
csvwrite(bbox_path, bbox_result);
