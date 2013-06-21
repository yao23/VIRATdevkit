function framedet = fusedetections(r,c,framedata,tpcount)
% Aim of this function is to fuse the intersecting detections and give a
% resulting bounding box that is average of all the fused bounding boxes
framedata = reshape(framedata,4,length(framedata)/4)';
% Converting framedata to more useful format
% r,c are column vectors of intersecting people
grouplabel = 1;
% Intializing the group
groups{grouplabel} = {[r(1),c(1)]};
for i = 1:length(r)
    emptycounter = 1;
    for j = 1:grouplabel
        if isempty(intersect([groups{j}{:}],[r(i),c(i)]))
            % Neither the row nor the column belongs - start a new group            
            if emptycounter == grouplabel
                grouplabel = grouplabel+1;
                groups{grouplabel} = {[r(i),c(i)]};
                break;
            end
            emptycounter = emptycounter+1;
        else
            % Merge the previous group with this group
            uniongrouped = union([groups{j}{:}],[r(i);c(i)]);
            groups{j} = {uniongrouped};
            break;
        end
    end
end
framedet = zeros(1,size(groups,2)*4);
% Getting fused detections from formed groups
for i = 1:size(groups,2)
    indices = [groups{i}{:}];
    currentxy = framedata(indices,:);
    framedet(1,(i-1)*4+1:i*4) = mean(currentxy);
end
% Assigning the rest of detections that are not part of groups
for i = 1:tpcount
    if ~(length(find(r==i))+length(find(c==i)))
        framedet(length(framedet)+1:length(framedet)+4) = framedata(i,:);
    end
end
end