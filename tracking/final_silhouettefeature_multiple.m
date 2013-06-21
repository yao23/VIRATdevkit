function [datamatrix,statematrix] = final_silhouettefeature_multiple(frame,framedir,...
    framenum,fb,statematrix,datamatrix)

% Inputs required
% frame - contains background subtraction data
% framedir - directory to original frames for doing optical flow
% framenum - current frame number
% nkltframes - how many frames should be tracked using KLT
% fb - tracking forward or backward
% Statematrix - Keep a tab on what people are doing
% Currentscene - people currently present in the scene
% lastframetrack - bounding box coordinates of tracking in last frame

% Tracking using background subtraction for each class
silresolution = 0.5;
% Human Silhouette Threshholds
Areathresh = 1000;
minAreathresh = 500;
minAreathreshratio = 0.3;
maxAreathreshratio = 100;

minareathreshfrac = 0.45; % successive bounding box area intersection fraction

gthresh = 0.3; % Threshold for group interaction
% Variable to check if the optical flow is evaluated for current frame
eflow = 0;

% Getting statistics of background subtraction
cc = bwconncomp(frame);
Stats = regionprops(cc,'Area','BoundingBox','Centroid');

% Considering some initial threshhold on the area of the human
% silhouette based on the imageresizeratio
humanthresh = find([Stats(:).Area]>minAreathreshratio*Areathresh &...
    [Stats(:).Area] < maxAreathreshratio*Areathresh &...
    [Stats(:).Area] > minAreathresh);

humbbox = zeros(length(humanthresh),4);
for i=1:length(humanthresh)
    humbbox(i,:) = [Stats(humanthresh(i)).BoundingBox]/silresolution;
end

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
    ind = find(statematrix{class}(framenum,:)==0);
    trackbbox = zeros(length(ind),4);
    for i = 1:length(ind)
        trackbbox(i,:) = lastframetrack(1+(ind(i)-1)*4:ind(i)*4);
    end
    
    % Also this list has to be appended by people where persons are
    % intersecting
    interactionind = find(statematrix{class}(framenum,:)>4);
    
    % If everything is detected and nothing needs to be tracked
    if (length(ind)+length(interactionind)) > 0
        
        % Calculating pascal ratio of each of these bounding boxes with input ones
        areaint = rectint(trackbbox,humbbox);
        areatrackbbox = trackbbox(:,3).*trackbbox(:,4);
        areahumbbox = humbbox(:,3).*humbbox(:,4);
        totalarea = repmat(areatrackbbox,1,size(areaint,2))+repmat(areahumbbox',size(areaint,1),1)-areaint;
        pascalratiomat = areaint./totalarea;
        
        % Each of these boxes has to be assigned to each of being tracked entity
        match = zeros(size(trackbbox,1),2);
        % Assigning these bounding boxes to each of the input ones
        for i=1:size(match,1)
            % There is not point in sorting if maximum of match matrix is 0
            if max(max(pascalratiomat)) > 0
                % Column sorting
                [sortedscore,indc] = sort(pascalratiomat,1,'descend');
                % Row sorting
                [sortedscore,indr] = sort(sortedscore,2,'descend');
                match(indc(1,indr(1,1)),1) = indr(1,1);
                match(indc(1,indr(1,1)),2) = sortedscore(1,1);
                pascalratiomat(indc(1,indr(1,1)),:) = zeros(1,size(pascalratiomat,2));
                pascalratiomat(:,indr(1,1)) = zeros(size(pascalratiomat,1),1);
            else
                % There is no point in sorting beacause no suitable detections
                % are available
                break;
            end
        end
        
        % Checking out each of the assigned tracking results
        for i = 1:size(match,1)
            if statematrix{class}(framenum,ind(i))~=1
                if match(i,2) >= minareathreshfrac
                    % This tracking result should be merged
                    trackedsildata(1+4*(ind(i)-1):4*ind(i)) = humbbox(match(i,1),:);
                    statematrix{class}(framenum,ind(i)) = 3;
                elseif isempty(humbbox)
                    % That means there was no movement in the scene
                    trackedsildata(1+4*(ind(i)-1):4*ind(i)) = lastframetrack(1+4*(ind(i)-1):4*ind(i));
                    statematrix{class}(framenum,ind(i)) = 3;
                elseif ~isempty(humbbox)
                    % Tracking using optical flow
                    if ~eflow
                        [flowx,flowy]=get_frame_flow(framedir,framenum,fb);
                        eflow=1;
                    end
                    bbox = lastframetrack(1+4*(ind(i)-1):4*ind(i));
                    trackedsildata(1+4*(ind(i)-1):4*ind(i)) = optical_tracking(flowx,flowy,bbox);
                    statematrix{class}(framenum,ind(i)) = 3;
                elseif match(i,1) == 0
                    if ~eflow
                        [flowx,flowy]=get_frame_flow(framedir,framenum,fb);
                        eflow=1;
                    end
                    bbox = lastframetrack(1+4*(ind(i)-1):4*ind(i));
                    trackedsildata(1+4*(ind(i)-1):4*ind(i)) = optical_tracking(flowx,flowy,bbox);
                    statematrix{class}(framenum,ind(i)) = 3;
                end
            end
        end
        
        % Assigning tracking data to group of people
        if ~isempty(interactionind)
            maxinteractionind = max(statematrix{class}(framenum,:));
            for i = 5:maxinteractionind
                % Tracking using extremities of blob
                currentind = find(statematrix{class}(framenum,:)==i);
                currentinddata = lastframetrack(1+4*(currentind(1)-1):4*currentind(1));
                if isempty(humbbox)
                    trackdata = currentinddata;
                elseif size(humbbox,1)==1
                    %Calculating pascal ratio of each of these bounding boxes with input ones
                    areaint = rectint(currentinddata,humbbox);
                    areatrackbbox = prod(currentinddata(3:4));
                    areahumbbox = humbbox(:,3).*humbbox(:,4);
                    totalarea = repmat(areatrackbbox,1,size(areaint,2))+repmat(areahumbbox',size(areaint,1),1)-areaint;
                    pascalratiomat = areaint./totalarea;
                    if max(pascalratiomat)>gthresh
                        trackdata = humbbox;
                    else
                        trackdata = currentinddata;
                    end
                else
                    trackdata = grouptrack(humbbox,currentinddata);
                end
                % Each of these boxes has to be assigned to each of being tracked entity
                for j = 1:length(currentind)
                    trackedsildata(1+4*(currentind(j)-1):4*currentind(j)) = trackdata;
                    statematrix{class}(framenum,currentind(j)) = i;
                end
            end
        end
    end
    datamatrix{class}(framenum,:) = trackedsildata;
end
end

