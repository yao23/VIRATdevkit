% Coupling intersecting people into groups
function [statematrix,datamatrix] = intersectingsets(r,c,statematrix,framenum,endframe,datamatrix)
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
% Changing corresponding elements in statematrix
for i = 1:size(groups,2)
    indices = [groups{i}{:}];
    currentxy = zeros(length(indices),4);
    for j = 1:length(indices)
        currentxy(j,:) = [datamatrix(framenum,(indices(j)-1)*4+1:(indices(j)-1)*4+2),...
            datamatrix(framenum,(indices(j)-1)*4+1:(indices(j)-1)*4+2)+...
            datamatrix(framenum,(indices(j)-1)*4+3:(indices(j)-1)*4+4)];
    end
    % Getting the parameters where the group is distributed
    xmin = min(currentxy(:,1));
    ymin = min(currentxy(:,2));
    xmax = max(currentxy(:,3));
    ymax = max(currentxy(:,4));
    for j = 1:length(indices)
        statematrix(framenum:endframe,indices(j)) = i+4;
        datamatrix(framenum,(indices(j)-1)*4+1:(indices(j))*4) = [xmin ymin xmax-xmin ymax-ymin];
    end
end
        


