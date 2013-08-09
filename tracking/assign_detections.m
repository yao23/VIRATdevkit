function [statematrix,datamatrix,currentscene,detectnum] = assign_detections(...
    statematrix,framenum,fb,datamatrix,detdata,currentscene,detectnum)
% Minimum ratio of intersection
minareathresh = 0.1;

dbstop if error;
% Assigning detection to each class by checking class specific detection
for class = 1:length(datamatrix)
    % Only if there is something in the current datamatrix
    if size(datamatrix{class},2)>0
        % Statematrix could also be filled by collision module
        areainteg =  rectint(reshape(datamatrix{class}(framenum-fb,:)',4,...
            length(datamatrix{class}(framenum-fb,:))/4)',reshape(detdata{class}(framenum,:)...
            ,4,length(detdata{class}(framenum,:))/4)');
        % Picking out the third and fourth element of datamatrix and same for
        % detections to get pascal ratio
        areamat = repmat((datamatrix{class}(framenum-fb,3:4:end).*datamatrix{class}(framenum-fb,...
            4:4:end))',1,size(areainteg,2))+repmat(detdata{class}(framenum,3:4:end).*detdata{class}...
            (framenum,4:4:end),size(areainteg,1),1);
        areadisjoint = areamat-areainteg;
        pascalratiomat = areainteg./areadisjoint;
        % Storing the original pascalratio matrix
        org_pmat = pascalratiomat;
        
        % Sorting pascalratiomat for assigning detections
        % Each of the current detections stored in datamatrix to be assigned
        match = zeros(size(datamatrix{class},2)/4,2);
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
        
        % Finding matching score that are good
        currentdetect = detdata{class}(framenum,:);
        for i = 1:size(match,1)
            if match(i,2) > minareathresh
                % This detection should be merged
                datamatrix{class}(framenum,1+4*(i-1):4*i) = detdata{class}...
                    (framenum,1+(match(i,1)-1)*4:match(i,1)*4);
                % Last detection
                statematrix{class}(framenum,i) = 4;
                % Current detection has been assigned
                int_ind = (find(org_pmat(i,:)>minareathresh));
                for j = 1:length(int_ind)
                currentdetect(1+(int_ind(j)-1)*4:int_ind(j)*4) = zeros(1,4);
                end
                % Since a detection was assigned to a track, all the other 
                % detections should be removed as all that intersect
                
            end
        end
        
        % Everything valid has been assigned, check for new detections
        if length(find(currentdetect)) >=2
            % Novel unassigned detection, have to start a new track
            if (length(find(currentdetect(3:4:end)))>1)
            cdind = detections_nms(currentdetect,...
                find(currentdetect(3:4:end)));
            else
                cdind = find(currentdetect(3:4:end));
            end
            for i = 1:length(cdind)
                detectnum{class} = detectnum{class}+1;
                currentscene{class} = [currentscene{class} detectnum];
                % Updating datamatrix
                datamatrixnew = zeros(size(datamatrix{class},1),size(datamatrix{class},2)+4);
                datamatrixnew(:,1:size(datamatrix{class},2)) = datamatrix{class};
                datamatrix{class} = datamatrixnew;
                datamatrix{class}(framenum,end-3:end) = currentdetect(4*(cdind(i)-1)+1:4*cdind(i));
                % Also writing this data to previous frame to keep track
                datamatrix{class}(framenum-fb,end-3:end) = datamatrix{class}(framenum,end-3:end);
                % Updating statematrix
                statematrixnew = zeros(size(statematrix{class},1),size(statematrix{class},2)+1);
                statematrixnew(:,1:size(statematrix{class},2)) = statematrix{class};
                statematrix{class} = statematrixnew;
                statematrix{class}(framenum,end) = 4;
                % Entry point for new person
                statematrix{class}(framenum-fb,end) = 4;
                %statematrix(framenum-2*fb,end) = 1;
            end
        end
    end
end
end