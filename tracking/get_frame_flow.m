function [flowx,flowy]=get_frame_flow(framedir,framenum,fb)
scale = 0.5;
% Get optical flow
I1 = imread([framedir '/' sprintf('%06d.jpg',framenum-fb)]);
I1 = imresize(I1,scale,'bicubic');
I1 = double(rgb2gray(I1))/255.0;
I2 = imread([framedir '/' sprintf('%06d.jpg',framenum)]);
I2 = imresize(I2,scale,'bicubic');
I2 = double(rgb2gray(I2))/255.0;
currframedata = getflow(I1,I2);
% Reading optical flow data for current frame
flowx = currframedata(:,:,1);
flowy = currframedata(:,:,2);
end
