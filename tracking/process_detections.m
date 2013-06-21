function [hbboxdata_od,status,startframe] = process_detections(rawbbdata,classid)

% Parameters
hbboxresolution = 1;
areafracthresh = 0.2;
% Counting the number of frames which have detection
nfcount = 0;
% Lower bound on frames where detection needs to be there
lfbound = 10;
% Status telling whether current object is present in the scene
status = 0;
% Detecting the start frame for tracking
startframe = 0;

reqinddata = zeros(size(rawbbdata,1),1);
% Getting the maximum detection size for current class
for i = 1:size(rawbbdata,1)
    reqinddata(i) = length(find(rawbbdata(i,1:6:end)==classid));
end
maxdetclass = max(reqinddata);
if maxdetclass>0
    bbox_od = zeros(size(rawbbdata,1),maxdetclass*4);
    for i = 1:size(rawbbdata,1)
        if reqinddata(i)>0
            ind = find(rawbbdata(i,1:6:end) == classid);
            for j = 1:reqinddata(i)
                bbox_od(i,(j-1)*4+1:j*4) = rawbbdata(i,(ind(j)-1)*6+2:ind(j)*6-1);
            end
        end
    end
    endframe = size(bbox_od,1);
    % Further processing only if there is atleast one detection on entire
    % video
    if size(bbox_od,2) >1
        hbboxdata_od = zeros(size(bbox_od,1),size(bbox_od,2));
        
        for i=1:size(hbboxdata_od,1)
            tpcount = 0;
            for j=1:size(bbox_od,2)/4
                if bbox_od(i,(j-1)*4+3:j*4) > [0 0]
                    hbboxdata_od(i,4*tpcount+1:4*tpcount+4) = [bbox_od(i,(j-1)*4+1:(j-1)*4+2),...
                        bbox_od(i,(j-1)*4+3:j*4)-bbox_od(i,(j-1)*4+1:(j-1)*4+2)]/hbboxresolution;
                    tpcount = tpcount+1;
                end
            end
            if tpcount>0
                nfcount = nfcount+1;
                if nfcount==1
                    startframe =i;
                end
            end
            % If in a frame there are more than one bouding box, we want to keep
            % non interesecting boxes only and if they are intersecting select the
            % smaller box
            if tpcount >1
                modifiedcurrentbox = reshape(hbboxdata_od(i,:),4,length(hbboxdata_od(i,:))/4)';
                areamat = rectint(modifiedcurrentbox,modifiedcurrentbox);
                areavec = hbboxdata_od(i,3:4:end).*hbboxdata_od(i,4:4:end);
                areasum = repmat(areavec,size(areamat,1),1)+repmat(areavec',1,size(areamat,1));
                pascalratiomat = areamat./(areasum-areamat);
                [r,c] = find(triu(pascalratiomat,1)>areafracthresh);
                if ~isempty(r)
                    framedet = fusedetections(r,c,hbboxdata_od(i,:));
                    hbboxdata_od(i,:) = zeros(1,size(hbboxdata_od,2));
                    hbboxdata_od(i,1:length(framedet)) = framedet;
                end
            end
        end
        
        % Pruning width of hbboxdata_od
        lengthmat = zeros(endframe,1);
        for i = 1:endframe
            if ~isempty(find(hbboxdata_od(i,:),1,'last'))
                lengthmat(i,1) = find(hbboxdata_od(i,:),1,'last');
            end
        end
        
        lengthmax = max(lengthmat);
        
        if lengthmax < size(hbboxdata_od,2)
            hbboxdata_odnew = hbboxdata_od(:,1:lengthmax);
            hbboxdata_od = hbboxdata_odnew;
        end
    end
    % Checking whether current object is present in the scene
%     if nfcount>lfbound
%         status = 1;
%     end
else
    % No detection for current class in this video
    status = 1;
end
end