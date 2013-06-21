% Visualizing human detections
clc;clear all;close all;
videofilename = 'FOLLOW7_A1_C1_Act2_URBAN_MR_AFTN_439463f4-1dc6-11e0-ad1b-e80688ca39a2.mov';
% Video Data
viddirectory = '/big2t/DARPA_DATA/minds-eye-y1-improvement';
% Bounding Box Data
bboxdirectory = '/big2t/Middles/tracks/C-Y1I';

hbboxresolution = 1;

% Making video flag
visflag = 0;
% Writing a video if needed
if visflag
    vidObj = VideoWriter('trackingout_final.avi');
    vidObj.FrameRate = 24;
    open(vidObj);    
end

videoobj = VideoReader([viddirectory '/' videofilename]);
maxframe = videoobj.NumberOfFrames-2;

% Reading bounding box
bbox_od = csvread([bboxdirectory '/' videofilename(1:end-4) '.csv']);

% Displaying bounding boxes in various colors
colorvec = ['r' 'g' 'b' 'y' 'm' 'c' 'k' 'r' 'g' 'b'];
maxframe = min(maxframe,size(bbox_od,1));

for framenum = 1:maxframe
    try
        im_current = read(videoobj,framenum);
        hold off;
        imshow(im_current);
        hold on;
    end
    
    tpcount = 0;
    % Processing data
    for j=1:(size(bbox_od,2)-1)/4
        % Displaying all the tracks of people
        if bbox_od(framenum,(j-1)*4+4:j*4+1)>[0 0]
            currentbox = [bbox_od(framenum,(j-1)*4+2:(j-1)*4+3),...
                bbox_od(framenum,(j-1)*4+4:j*4+1)-bbox_od(framenum,(j-1)*4+2:(j-1)*4+3)]/hbboxresolution;
            tpcount = tpcount+1;
            rectangle('Position',currentbox,'EdgeColor',colorvec(tpcount),'LineWidth',4);
        end
    end
    drawnow;
    if visflag
        % Get current frame
        im_vid = getframe(gca);
        im = im_vid.cdata;
        im = im(1:720,1:1280,:);
        writeVideo(vidObj,im);
    end
    %     imwrite(frame,sprintf('%s/img%05d.png',imgwritedir,framenum),'png');
end
close(vidObj);
