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
    tracks{i}.csv = csvread([tracks_path, '/', tracks_dir(i+2,1).name]);
    tracks{i}.frame = size(tracks{i}.csv, 1);
    tracks{i}.num = size(tracks{i}.csv, 2)/4;
    tracks{i}.id = str2num(tracks_dir(i+2,1).name(1:end-4));
    tracks{i}.name = label(tracks{i}.id);
    frame(i,1) = tracks{i}.frame;
end

video_dir = dir(video_path);
frame_num = length(video_dir) - 2;

fid = fopen([outcsv_path '/attribute.csv'], 'a');
fprintf(fid, '%s\n', '<tml>');

for i=1:frame_num
     
    impath = sprintf('%s/%06d.jpg', video_path, i);
    im = imread(impath);
    imshow(im,'border','tight');
    
    [I_h, I_w, d] = size(im);
    set(gca,'Units','normalized','Position',[0 0 1 1]);  %# Modify axes size
    set(gcf,'Units','pixels','Position',[200 200 I_w I_h]);  %# Modify figure size
    
    hold on;
    
    for j=1:tracks_num
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
                           person_height(fid, video_id, i, 1, (k+object_offset), x1_output, y1_output,  x2_output, y2_output);
                        case 2
                           vehicle_color(fid, video_id, i, 2, (k+object_offset), x1_output, y1_output,  x2_output, y2_output, impath);
                        case 3
                           vehicle_color(fid, video_id, i, 3, (k+object_offset), x1_output, y1_output,  x2_output, y2_output, impath);
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
     
    savepath = sprintf('%s/%06d.png', outimage_path, i);
    f = getframe(gcf);
    imwrite(f.cdata, savepath);
    close(gcf);
end

fprintf(fid, '%s\n', '</tml>');
fclose(fid);

end

function person_height(fid, video_id, frame_id, class_id, object_id, x1, y1, x2, y2)

fprintf(fid, '%s', '<data ref="CAM_UB">');
fprintf(fid, '%d', frame_id);

[longitude, latitude] = time_space(fid, video_id, frame_id);

height = y2 - y1;
if height >= 150
   height_types = 'tall';
elseif height >= 100
   height_types = 'medium';
else
   height_types = 'short';
end

[longitude_offset, latitude_offset] = space_process(x1, y1, x2, y2);

fprintf(fid, ',');
fprintf(fid,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.3f,%.3f,%s,%.3f,%.3f', class_id, object_id, x1, y1, x2, y2, latitude+latitude_offset, longitude+longitude_offset, height_types, latitude, longitude);
fprintf(fid, '%s\n', '</data>');

end

function vehicle_color(fid, video_id, frame_id, class_id, object_id, x1, y1, x2, y2, im)

fprintf(fid, '%s', '<data ref="CAM_UB">');
fprintf(fid, '%d', frame_id);

[longitude, latitude] = time_space(fid, video_id, frame_id);

img = imread(im);
 
x1_crop = int64(x1);
y1_crop = int64(y1);
x2_crop = int64(x2);
y2_crop = int64(y2);
vehs_crop = img(y1_crop:y2_crop, x1_crop:x2_crop, :);
color_types = rgbhist(vehs_crop);
[longitude_offset, latitude_offset] = space_process(x1, y1, x2, y2);

fprintf(fid, ',');
fprintf(fid,'%d,%d,%.2f,%.2f,%.2f,%.2f,%.3f,%.3f,%s,%.3f,%.3f', class_id, object_id, x1, y1, x2, y2, latitude+latitude_offset, longitude+longitude_offset, color_types, latitude, longitude);
fprintf(fid, '%s\n', '</data>');

end

function [longitude_offset, latitude_offset] = space_process(x1, y1, x2, y2)

central_x = 960;
central_y = 540;

longitude_offset = (central_x - (x1 + x2)/2)/10000;
latitude_offset = (central_y - (y1 + y2)/2)/10000;

end

function [longitude, latitude] = time_space(fid, video_id, frame_id)

year = 2010;
                    
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

