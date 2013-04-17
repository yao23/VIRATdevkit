function virat_videobbox(im, index, outimage_path, bbox_frame, models)
% virat_videobbox(im, bbox_frame, models)
% im: image
% outimage_path: path to your image output
% bbox_frame: a row of bounding box
% models: loaded models

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


imshow(im);
if ~isempty(bbox_frame)
    try
        [I_h, I_w, d] = size(im);
        set(gca,'Units','normalized','Position',[0 0 1 1]);  %# Modify axes size
        set(gcf,'Units','pixels','Position',[200 200 I_w I_h]);  %# Modify figure size
        hold on;
        bbox_num = sum(int8(bbox_frame(1,1:5:end)>0));
        if bbox_num > 0
            for j=1:bbox_num
                x1 = floor(bbox_frame(1, (j-1)*5+2))+1;
                y1 = floor(bbox_frame(1, (j-1)*5+3))+1;
                x2 = floor(bbox_frame(1, (j-1)*5+4));
                y2 = floor(bbox_frame(1, (j-1)*5+5));
                id = bbox_frame(1, (j-1)*5+1);
                annotation('textbox', [x1/I_w, (I_h - y2)/I_h, (x2 - x1)/I_w, (y2 - y1)/I_h], ...
                    'LineWidth', 3, 'edgecolor', colororder(id, :), ...
                    'String', models{id}.model.class, ...
                    'fontsize', 14, 'color', colororder(id, :), 'fontweight', 'bold');
            end
        end
    catch
        warning('wrong with anno draw');
    end
end
savepath = sprintf('%s/%05d.png', outimage_path, index);
f = getframe(gcf);
imwrite(f.cdata, savepath);
close(gcf);
