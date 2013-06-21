function [statematrix,datamatrix] = group_detections(statematrix,framenum,fb,datamatrix,detdata,framedir,data)
% Forming groups only with detections on same classes
for class = 1:length(datamatrix)
% Getting detections having intersection with current groups people
if length(find(statematrix{class}(framenum,:)>4)) > 0
    maxinteractionind = max(statematrix{class}(framenum,:));
    for i = 5:maxinteractionind
        % Getting previous frame data
        ind = find(statematrix{class}(framenum,:)==i);
        if ~isempty(ind)
            % Getting previous tracked for current group
            trackeddata = datamatrix{class}(framenum-fb,(ind(1)-1)*4+1:ind(1)*4);
            % Checking number of detections available on current group
            areainteg =  rectint(trackeddata,reshape(detdata{class}(framenum,:),...
                4,length(detdata{class}(framenum,:))/4)');
            areamat = [detdata{class}(framenum,3:4:end).*detdata{class}(framenum,4:4:end)];
            pascalratiomat = areainteg./areamat;
            % Finding intersection that atleast has 50% in the group
            detectionreq = find(pascalratiomat>0.5);
            if length(detectionreq)==length(ind)
                % Number of detections is equal to people in group
                testbbox = zeros(length(ind),4);
                inpbbox = zeros(length(ind),4);
                inputframeno = zeros(length(ind),1);
                for j = 1:length(ind)
                    testbbox(j,:) = detdata{class}(framenum,(detectionreq(j)-1)*4+1:detectionreq(j)*4);
                    % Removing this entry from hbboxdata_od so that
                    % remaining process doesn't assign it any box
                    detdata{class}(framenum,(detectionreq(j)-1)*4+1:detectionreq(j)*4) = zeros(1,4);
                    % To find input bbox, search for all the detection
                    lastdetectind = find(statematrix{class}(:,ind(j))==4);
                    inputframeno(j) = lastdetectind(1);
                    inpbbox(j,:) = datamatrix{class}(lastdetectind(1),(ind(j)-1)*4+1:ind(j)*4);
                end
                % Now ask histmatch to match identities
                [match,~] = histmatch(framedir,data,inputframeno,framenum,inpbbox,testbbox);
                
                % If length of input and test bbox is same just
                if (size(inpbbox,1)==1)&&(size(testbbox,1)==1)
                    match = 1;
                end
                
                % Assigning detections according to the match
                for j = 1:length(ind)
                    datamatrix{class}(framenum,(ind(j)-1)*4+1:ind(j)*4) = testbbox(match(j),:);
                    statematrix{class}(framenum,ind(j))=4;
                    statematrix{class}(framenum+1:end,ind(j)) = zeros(size(statematrix{class},1)-framenum,1);
                    % Doing linear interpolation between current data
                    % and till there was interaction
                    trackind = find(statematrix{class}(:,ind(j))==3|statematrix{class}(:,ind(j))==4);
                    % Linearly interpolate from trackind(end)-->current
                    for k = 1:4
                        diff = ((datamatrix{class}(trackind(end-1),(ind(j)-1)*4+k)-...
                            datamatrix{class}(framenum,(ind(j)-1)*4+k))/(trackind(end-1)-framenum));
                        if diff~=0
                            datamatrix{class}(trackind(end-1):framenum,(ind(j)-1)*4+k) = ...
                                datamatrix{class}(trackind(end-1),(ind(j)-1)*4+k):diff:...
                                datamatrix{class}(framenum,(ind(j)-1)*4+k);
                        else
                            datamatrix{class}(trackind(end-1):framenum,(ind(j)-1)*4+k) = ...
                                datamatrix{class}(trackind(end-1),(ind(j)-1)*4+k)*ones(length(trackind(end-1):framenum),1);
                        end
                    end
                end
            end
            % If any single detection intersects with group, remove it
            detectionreq = find(pascalratiomat>0.3);
            for p = 1:length(detectionreq)
                detdata{class}(framenum,(detectionreq(p)-1)*4+1:detectionreq(p)*4) = zeros(1,4);
            end
        end
    end
end
end