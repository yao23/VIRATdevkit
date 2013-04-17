function video_tracks(video_path, outimage_path, tracks_path, idmap_path)
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

for i=1:frame_num
    impath = sprintf('%s/%06d.jpg', video_path, i);
%     impath = sprintf('%s/%06d.bmp', video_path, i);
    im = imread(impath);
    imshow(im,'border','tight');
    
    [I_h, I_w, d] = size(im);
    set(gca,'Units','normalized','Position',[0 0 1 1]);  %# Modify axes size
    set(gcf,'Units','pixels','Position',[200 200 I_w I_h]);  %# Modify figure size
    
    hold on;
    
    for j=1:tracks_num
        if i <= tracks{j}.frame
            for k=1:tracks{j}.num
                if sum(tracks{j}.csv(i,(k-1)*4+1:(k-1)*4+4)) > 0
                    x1 = floor(tracks{j}.csv(i,(k-1)*4+1));
                    y1 = floor(tracks{j}.csv(i,(k-1)*4+2));
                    w = floor(tracks{j}.csv(i,(k-1)*4+3));
                    h = floor(tracks{j}.csv(i,(k-1)*4+4));
                    
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
