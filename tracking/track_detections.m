function [datamatrix,statematrix,currentscene] = track_detections(data,datamatrix,statematrix,framenum,framedir,currentscene,im,fb)
% Defining frame to be sent for silhouette feature
if ~isempty(data)
    frame = permute(data(:,:,:,framenum),[4 2 3 1]);
    frame = permute(frame,[3 2 1]);
    frame = double(frame*255);
    [datamatrix,statematrix] = final_silhouettefeature_multiple(frame,framedir,...
    framenum,fb,statematrix,datamatrix);
else
    [datamatrix,statematrix] = optical_class_track(framedir,framenum,fb,statematrix,datamatrix);
end
% Last frame data for tracking
%lastframetrack = datamatrix(framenum-fb,:);


%datamatrix(framenum,:) = trackedsildata;

% Person scene exit detection
[datamatrix,statematrix,currentscene] = exit_decision(datamatrix,statematrix,framenum,fb,currentscene,im);

% Forming interactions
if ~isempty(data)
    [statematrix,datamatrix] = interaction_formation(statematrix,datamatrix,framenum);
end
end