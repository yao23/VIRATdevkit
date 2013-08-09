function videobbox(video_path, output_path, bbox_csv)
% videobbox(video_path, output_path, bbox_csv)
% video_path: path to your extracted video frames
% output_path: path to output directory
% bbox_csv: bounding box csv file

video_dir = dir(video_path);

bbox = csvread(bbox_csv);

frame_num = min(size(bbox, 1), length(video_dir)-2);
parfor i=1:frame_num
    impath = [video_path, '/', video_dir(i+2, 1).name];
    im = imread(impath);
    bbox_num = sum(bbox(i,1:5:end));
    if bbox_num > 0
        for j=1:bbox_num
            x1 = bbox(i, (j-1)*5+2) + 1;
            y1 = bbox(i, (j-1)*5+3) + 1;
            x2 = bbox(i, (j-1)*5+4);
            y2 = bbox(i, (j-1)*5+5);
            
            im(y1, x1:x2, :) = 255;
            im(y2, x1:x2, :) = 255;
            im(y1:y2, x1, :) = 255;
            im(y1:y2, x2, :) = 255;
        end
    end
    imsavepath = [output_path,'/',video_dir(i+2, 1).name];
    imwrite(im, imsavepath);
end