function video_tracks(video_path, outimage_path, tracks_path, idmap_path, outcsv_path, video_id)
% video_tracks(video_path, outimage_path, tracks_path)
% video_path: path to your extracted video frames
% outimage_path: path to output image directory
% tracks_path: path to tracking output csv folder
% idmap_path: path to id map file

% video_path = '/home/chenlian/aladdin_repo/test/HVC576709';
% outimage_path = '/home/chenlian/aladdin_repo/test/HVC576709_tracks';
% tracks_path = '/home/chenlian/aladdin_repo/test/HVC576709_trackimage';
% idmap_path = '/home/chenlian/aladdin_repo/test/HVC576709_csv/idmap.txt';

if ~exist(outimage_path, 'dir')
    mkdir(outimage_path);
end

% up to 20 models
colororder = [
    0.00  0.00  1.00
    0.00  0.50  0.00
    1.00  0.00  0.00
    0.00  0.75  0.75
    0.75  0.00  0.75
    0.75  0.75  0.00
    0.25  0.25  0.25
    0.75  0.25  0.25
    0.95  0.95  0.00
    0.25  0.25  0.75
    0.75  0.75  0.75
    0.00  1.00  0.00
    0.76  0.57  0.17
    0.54  0.63  0.22
    0.34  0.57  0.92
    1.00  0.10  0.60
    0.88  0.75  0.73
    0.10  0.49  0.47
    0.66  0.34  0.65
    0.99  0.41  0.23
    ];

% read idmap
idmap_fid = fopen(idmap_path, 'r');
idmap_file = textscan(idmap_fid, '%d %s %f\n');
label = idmap_file{1,2};

tracks_dir = dir(tracks_path);
tracks_num = length(tracks_dir)-2;

for i=1:tracks_num
    csv = csvread([tracks_path, '/', tracks_dir(i+2,1).name]);
    tracks{i}.csv = csv(:,2:end);
    % tracks{i}.csv = csv(:,2:9);
    tracks{i}.frame = size(tracks{i}.csv, 1);
    if size(tracks{i}.csv, 2) < 4 %%% test this
        tracks{i}.num = 0;
    else
        tracks{i}.num = size(tracks{i}.csv, 2)/4;
    end
    tracks{i}.id = str2num(tracks_dir(i+2,1).name(1:end-4));
    tracks{i}.name = label(tracks{i}.id);
    tracks{i}.startfrm = csv(1, 1);
    frame(i,1) = tracks{i}.frame;
end

video_dir = dir(video_path);
frame_num = length(video_dir) - 2;

% object_num = 0;
% for i=1:frame_num
%     for j=1:tracks_num
%         if i <= tracks{j}.frame
%             for k=1:tracks{j}.num
%                 if sum(tracks{j}.csv(i,(k-1)*4+1:(k-1)*4+4)) > 0
%                     object_num = object_num + 1;
%                 end
%             end
%         end
%     end
% end

object_IDs = [];
object_attribute = struct();

fid = fopen([outcsv_path '/attribute1.csv'], 'a');
fprintf(fid, '%s\n', '<tml>');

for i=1:frame_num
    if i == 1
        continue;
    end
    
    impath = sprintf('%s/%06d.jpg', video_path, i);
    im = imread(impath);
    imshow(im,'border','tight');
    
    [I_h, I_w, d] = size(im);
    set(gca,'Units','normalized','Position',[0 0 1 1]);  %# Modify axes size
    set(gcf,'Units','pixels','Position',[200 200 I_w I_h]);  %# Modify figure size
    
    hold on;
    
    for j=1:tracks_num
        if i < tracks{j}.startfrm
            continue
        end
        % establish global unique object ID
        object_offset = 0;
        if j > 1
           for m = 1:(j-1)
               object_offset = object_offset + tracks{m}.num;
           end
        end
        
        if i <= tracks{j}.frame
            for k=1:tracks{j}.num
                if sum(tracks{j}.csv(i,(k-1)*4+1:(k-1)*4+4)) > 0
                    x1 = floor(tracks{j}.csv(i,(k-1)*4+1));
                    y1 = floor(tracks{j}.csv(i,(k-1)*4+2));
                    w = floor(tracks{j}.csv(i,(k-1)*4+3));
                    h = floor(tracks{j}.csv(i,(k-1)*4+4));
                    
                    x1_output = tracks{j}.csv(i,(k-1)*4+1);
                    y1_output = I_h-(tracks{j}.csv(i,(k-1)*4+2))-h;
                    x2_output = (tracks{j}.csv(i,(k-1)*4+1))+w;
                    y2_output = I_h-(tracks{j}.csv(i,(k-1)*4+2));               
                                     
                    switch tracks{j}.id
                        case 1
                           [object_IDs, object_attribute] = person_height(fid, video_id, i, 1, (k+object_offset), x1_output, y1_output,  x2_output, y2_output, object_IDs, object_attribute);
                        case 2
                           [object_IDs, object_attribute] = vehicle_color(fid, video_id, i, 2, (k+object_offset), x1_output, y1_output,  x2_output, y2_output, impath, object_IDs, object_attribute);
                        case 3
                           [object_IDs, object_attribute] = vehicle_color(fid, video_id, i, 3, (k+object_offset), x1_output, y1_output,  x2_output, y2_output, impath, object_IDs, object_attribute);
                        otherwise
                           disp('invalid object class ID');
                    end
                                       
                    %                 try
                    annotation('textbox', [x1/I_w, (I_h-y1-h)/I_h, w/I_w, h/I_h], ...
                        'LineWidth', 3, 'edgecolor', colororder(tracks{j}.id, :), ...
                        'String', [tracks{j}.name,num2str(k)], 'fontsize', 14, 'color', colororder(tracks{j}.id, :), ...
                        'fontweight', 'bold');
                    
                    
                    %                 catch
                    %                     warning('wrong with anno draw');
                    %                 end
                end
            end
        end
    end
     
%     savepath = sprintf('%s/%06d.png', outimage_path, i);
    savepath = sprintf('%s/%06d.png', outimage_path, i-1); % move backword 1
    f = getframe(gcf);
    imwrite(f.cdata, savepath);
    close(gcf);
end

fprintf(fid, '%s\n', '</tml>');
fclose(fid);

end

function [object_IDs, object_attribute] = person_height(fid, video_id, frame_id, class_id, object_id, x1, y1, x2, y2, object_IDs, object_attribute)

fprintf(fid, '%s', '<data ref="CAM_UB">');
fprintf(fid, '%d', frame_id);

[longitude, latitude] = time_space(fid, video_id, frame_id);

if ismember(object_id, object_IDs)
    height_types = object_attribute(object_id).attribute;
else
    object_IDs = [object_IDs, object_id];
    height_types = height_process(y1, y2);
    object_attribute(object_id).id = object_id;
    object_attribute(object_id).attribute = height_types;
end

% if object_attribute{object_id}.flag == false
%     object_attribute{object_id}.attribute = height_types;
%     object_attribute{object_id}.flag = true;
% end

[longitude_offset, latitude_offset] = space_process(x1, y1, x2, y2, video_id);

fprintf(fid, ',');
fprintf(fid,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.3f,%.3f,%s,%.3f,%.3f', class_id, object_id, x1, y1, x2, y2, latitude+latitude_offset, longitude+longitude_offset, height_types, latitude, longitude);
fprintf(fid, '%s\n', '</data>');

end

function [object_IDs, object_attribute] = vehicle_color(fid, video_id, frame_id, class_id, object_id, x1, y1, x2, y2, im, object_IDs, object_attribute)

fprintf(fid, '%s', '<data ref="CAM_UB">');
fprintf(fid, '%d', frame_id);

[longitude, latitude] = time_space(fid, video_id, frame_id);

if ismember(object_id, object_IDs)
    color_types = object_attribute(object_id).attribute;
else
    img = imread(im);
    x1_crop = max(int64(x1), 1);
    y1_crop = max(int64(y1), 1);
    x2_crop = int64(x2);
    y2_crop = int64(y2);
    vehs_crop = img(y1_crop:y2_crop, x1_crop:x2_crop, :);
    color_types = rgbhist(vehs_crop);

    object_IDs = [object_IDs, object_id];
    object_attribute(object_id).id = object_id;
    object_attribute(object_id).attribute = color_types;
end

[longitude_offset, latitude_offset] = space_process(x1, y1, x2, y2, video_id);

fprintf(fid, ',');
fprintf(fid,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.3f,%.3f,%s,%.3f,%.3f', class_id, object_id, x1, y1, x2, y2, latitude+latitude_offset, longitude+longitude_offset, color_types, latitude, longitude);
fprintf(fid, '%s\n', '</data>');

end

function height_type = height_process(y1, y2)

height = y2 - y1;
if height >= 150
   height_type = 'tall';
elseif height >= 100
   height_type = 'medium';
else
   height_type = 'short';
end

end

function [longitude_offset, latitude_offset] = space_process(x1, y1, x2, y2, video_id)

if video_id < 67 %%% VIRAT
    central_x = 960;
    central_y = 540;
elseif video_id < 76 %%% PSU
    central_x = 320;
    central_y = 240;
else  %%% TSU (video_id >= 76)
    central_x = 160;
    central_y = 120;
end
longitude_offset = (central_x - (x1 + x2)/2)/10000;
latitude_offset = (central_y - (y1 + y2)/2)/10000;

end

function [longitude, latitude] = time_space(fid, video_id, frame_id)

year = 2010;

if video_id < 67 %%% VIRAT
    if video_id < 6 %%% 1st scene in VIRAT (1-5)
        latitude = 32.507;  longitude = 47.285;    
        month = 3;    day = video_id - 1 + 16;
        hour = 13;    minute = 23 + video_id;    second = 16 + frame_id;
%     [month, day, hour, minute, second] = time_process(month, day, hour, minute, second);
    elseif video_id < 42 %%% 2nd scene in VIRAT (6-41)
        latitude = 33.507;  longitude = 45.827;    
        month = 4;    day = video_id - 5;
        hour = 10;    minute = 13 + (video_id - 5);    second = 15 + frame_id;
%     [month, day, hour, minute, second] = time_process(month, day, hour, minute, second);
    else %%% video_id < 67, 3rd scene in VIRAT (42-66)
        latitude = 33.505;  longitude = 48.276;    
        month = 5;    day = video_id - 41;
        hour = 15;    minute = 33 + (video_id - 41);    second = 14 + frame_id;
%     [month, day, hour, minute, second] = time_process(month, day, hour, minute, second);
    end
elseif video_id < 76 %%% PSU dataset (71 - 75)
    switch video_id 
        case 71
            latitude = 33.30094;    longitude = 44.39491;    
            month = 2; day = 8; hour = 13; minute = 0; second = 5 + frame_id;
        case 72
            latitude = 33.317969;   longitude = 44.394051;    
            month = 3; day = 3; hour = 14; minute = 22; second = 40 + frame_id;
        case 73
            latitude = 33.31823;    longitude = 44.29661;  
            month = 3; day = 4; hour = 7; minute = 10; second = frame_id;
        case {74, 75}
            latitude = 33.29586;    longitude = 44.34139;   
            month = 3; day = 3; hour = 10; minute = 12; second = frame_id;
    end
elseif video_id < 81 %%% simple version TSU dataset (76-80)
    latitude = 33.246653;   longitude = 44.396994;    
    month = 1; day = 27; hour = 13; minute = 00; second = 5 + frame_id;
else %%% complete version TSU dataset (81 - 100)
    switch video_id % PSU dataset (71 - 75)
        case 81
            latitude = 33.246653;   longitude = 44.396994;    
            month = 1; day = 27; hour = 10; minute = 0; second = frame_id;
        case 82
            latitude = 33.2466482;   longitude = 44.3969883;    
            month = 3; day = 18; hour = 12; minute = 0; second = frame_id;
        case {83, 93}
            latitude = 33.31823;    longitude = 44.29661;  
            month = 1; day = 26; hour = 12; minute = 0; second = frame_id;
            if video_id == 93
                hour = 11; minute = 11; second = 21 + frame_id;
            end
        case 84
            latitude = 33.232587;    longitude = 44.372555;   
            month = 3; day = 16; hour = 10; minute = 30; second = frame_id;
        case 85
            latitude = 35.452184;    longitude = 44.179044;    
            month = 3; day = 29; hour = 11; minute = 15; second = frame_id;
        case 86
            latitude = 33.100069;   longitude = 44.583332;    
            month = 3; day = 29; hour = 10; minute = 0; second = frame_id;
        case 87
            latitude = 33.244359;   longitude = 44.376346;    
            month = 4; day = 3; hour = 11; minute = 45; second = frame_id;
        case {88, 92}
            latitude = 33.212756;    longitude = 44.374993;  
            month = 3; day = 10; hour = 13; minute = 0; second = frame_id;
            if video_id == 92
                hour = 9;
            end
        case 89
            latitude = 33.212756;    longitude = 44.374993;   
            month = 3; day = 16; hour = 13; minute = 0; second = frame_id;
        case 90
            latitude = 33.212756;    longitude = 44.374993;    
            month = 3; day = 28; hour = 9; minute = 0; second = frame_id;
        case 91
            latitude = 33.212756;   longitude = 44.374993;    
            month = 3; day = 5; hour = 9; minute = 0; second = 5 + frame_id;
        case 94
            latitude = 33.2466482;   longitude = 44.3969883;    
            month = 1; day = 27; hour = 11; minute = 22; second = 47 + frame_id;
        case {95, 96}
            latitude = 33.2529985;    longitude = 44.406424;  
            month = 2; day = 10; hour = 8; minute = 33; second = 50 + frame_id;
            if video_id == 96
                hour = 9; minute = 8; second = 49 + frame_id;
            end
        case 97
            latitude = 34.12456;    longitude = 45.34543;    
            month = 3; day = 19; hour = 8; minute = 14; second = 23 + frame_id;
        case 98
            latitude = 33.2564417;   longitude = 44.3947095;    
            month = 4; day = 6; hour = 12; minute = 16; second = 37 + frame_id;
        case 99
            latitude = 33.2590205;   longitude = 44.3982561;    
            month = 4; day = 6; hour = 9; minute = 26; second = 48 + frame_id;
        case 100
            latitude = 33.2443546;    longitude = 44.3763406;  
            month = 4; day = 2; hour = 15; minute = 12; second = 21 + frame_id;
    end
end

[month, day, hour, minute, second] = time_process(month, day, hour, minute, second);
fprintf(fid, ',');
fprintf(fid,'%04d-%02d-%02dT%02d:%02d.%02d', year, month, day, hour, minute, second);

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

