function [datamatrix,statematrix] = optical_class_track(framedir,framenum,fb,statematrix,datamatrix)
[flowx,flowy]=get_frame_flow(framedir,framenum,fb);
% Tracking for individual classes
for class = 1:length(datamatrix)
    lastframetrack = datamatrix{class}(framenum-fb,:);
    trackedsildata = zeros(1,length(lastframetrack));
    % Assigning all the detections
    detectind = find(statematrix{class}(framenum,:)==4);
    for l = 1:length(detectind)
        trackedsildata(1+(detectind(l)-1)*4:detectind(l)*4) = datamatrix{class}(framenum,1+(detectind(l)-1)*4:detectind(l)*4);
    end
    
    % Finding objects that need to be tracked using silhouettes
    %ind = find(statematrix{class}(framenum,:)==0);
    ind = 1:length(lastframetrack)/4;
    trackbbox = zeros(length(ind),4);
    for i = 1:length(ind)
        trackbbox(i,:) = lastframetrack(1+(ind(i)-1)*4:ind(i)*4);
        if trackbbox(i,:)~=[0 0 0 0]
            currbbox = optical_tracking(flowx,flowy,trackbbox(i,:));
            lastframetrack(1+(ind(i)-1)*4:ind(i)*4) = currbbox;
            statematrix{class}(framenum,ind(i))=3;
        else
            lastframetrack(1+(ind(i)-1)*4:ind(i)*4) = trackbbox(i,:);
        end
    end
    datamatrix{class}(framenum,1:length(lastframetrack)) = lastframetrack;
end
end