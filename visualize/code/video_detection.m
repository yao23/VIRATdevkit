function video_detection(video_path, outimage_path, bbox_path, idmap_path)
% video_detection(video_path, output_path, bbox_path, idmap_path)
% video_path: path to your extracted video frames
% outimage_path: path to output image directory
% bbox_path: path to bounding box csv file
% idmap_path: path to id map file

% video_path = '../../test/HVC576709';
% outimage_path = '../../test/HVC576709_detimage_detection_num';
% bbox_path = '../../test/HVC576709_csv_detection_num/detection.csv';
% idmap_path = '../../test/HVC576709_csv_detection_num/idmap.txt';

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

video_dir = dir(video_path);
bbox = csvread(bbox_path);
det_num = size(bbox, 1);
for i=1:det_num
    try
%         impath = sprintf('%s/%06d.bmp', video_path, bbox(i,1));
        impath = sprintf('%s/%06d.jpg', video_path, bbox(i,1));
%         impath = sprintf('%s/%06d.JPG', video_path, bbox(i,1));
        im = imread(impath);
        imshow(im, 'Border', 'tight');
        
        [I_h, I_w, d] = size(im);
        %     set(gca,'Units','normalized','Position',[0 0 1 1]);  %# Modify axes size
        %     set(gcf,'Units','pixels','Position',[200 200 I_w I_h]);  %# Modify figure size
        
        hold on;
        
        bbox_num = sum(int8(bbox(i,2:5:end)>0));
        if bbox_num > 0
            for j=1:bbox_num
                id = bbox(i, (j-1)*5+2);
                x1 = floor(bbox(i, (j-1)*5+3))+1;
                y1 = floor(bbox(i, (j-1)*5+4))+1;
                x2 = floor(bbox(i, (j-1)*5+5));
                y2 = floor(bbox(i, (j-1)*5+6));
                
                if id == 1
                    annotation('textbox', [x1/I_w, (I_h - y2)/I_h, (x2 - x1)/I_w, (y2 - y1)/I_h], ...
                        'LineWidth', 3, 'edgecolor', colororder(id, :), ...
                        'String', label{id}, 'fontsize', 32, 'color', colororder(id, :), ...
                        'fontweight', 'bold', 'Interpreter', 'none');
                else
                    annotation('textbox', [x1/I_w, (I_h - y2)/I_h, (x2 - x1)/I_w, (y2 - y1)/I_h], ...
                        'LineWidth', 3, 'edgecolor', colororder(id, :), ...
                        'String', label{id}, 'fontsize', 32, 'color', colororder(id, :), ...
                        'fontweight', 'bold', 'Interpreter', 'none');
                end
            end
        end
        
        savepath = sprintf('%s/%06d.png', outimage_path, bbox(i,1));
        f = getframe(gcf);
        imwrite(f.cdata, savepath);
        close(gcf);
        
    catch
        warning('wrong with anno draw');
    end
end
