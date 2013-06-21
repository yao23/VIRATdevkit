function [statematrix,datamatrix] = interaction_formation(statematrix,datamatrix,framenum)

% For collision detection pascal ratio
collisionpascal = 0.15;
endframe = size(datamatrix{1},1);
for class = 1:length(datamatrix)
    % Trying to see if their is collision or interaction using rectint
    collisionrect = reshape(datamatrix{class}(framenum,:)',4,length(datamatrix{class}(framenum,:))/4)';
    rectcollisiondata = rectint(collisionrect,collisionrect);
    % Pascal ratio mat
    rectcollisionratio = rectcollisiondata./(repmat(datamatrix{class}(framenum,3:4:end).*datamatrix{class}(framenum,4:4:end),...
        size(rectcollisiondata,1),1)+repmat([datamatrix{class}(framenum,3:4:end).*datamatrix{class}(framenum,4:4:end)]',...
        1,size(rectcollisiondata,1)));
    % Finding nonzero entries apart from self intersections
    reqmatrix = triu(rectcollisionratio,1);
    [r,~] = find(reqmatrix>0);
    if ~isempty(r)
        % If nothing was intersecting until current frame
        if statematrix{class}(framenum,:)<5
            % Case when something is intersecting
            [r,c] = find(reqmatrix>collisionpascal);
            if ~isempty(r)
                % People are labeled as interesecting which need to be resolved
                [statematrix{class},datamatrix{class}] = intersectingsets(r,c,statematrix{class},framenum,endframe,datamatrix{class});
            end
        else
            % There are some groups already
            [r,c] = find(reqmatrix>collisionpascal);
            % Non intersecting humans
            nonintind = find(statematrix{class}(framenum,:)<5);
            if ~isempty(nonintind)
                % Getting all the data for non intersecting people
                nonintinddata = zeros(length(nonintind),4);
                for m = 1:length(nonintind)
                    nonintinddata(m,:) = datamatrix{class}(framenum,(nonintind(m)-1)*4+1:nonintind(m)*4);
                end
                % Area vector of non intersecting int data
                areanonint = [nonintinddata(:,3).*nonintinddata(:,4)]';
                % Matching this data against each group
                maxinteractionind = max(statematrix{class}(framenum,:));
                for l = 5:maxinteractionind
                    currentind = find(statematrix{class}(framenum,:)==l);
                    currtrackbbox = datamatrix{class}(framenum,(currentind(1)-1)*4+1:currentind(1)*4);
                    rectcollisiondata = rectint(currtrackbbox,nonintinddata);
                    pascalratiomat = rectcollisiondata./areanonint;
                    rnew = find(pascalratiomat>collisionpascal);
                    rnew = [nonintind(rnew)]';
                    cnew = repmat(currentind(1),length(rnew),1);
                    r = [r;rnew];
                    c = [c;cnew];
                end
                if ~isempty(r)
                    [statematrix{class},datamatrix{class}] = intersectingsets(r,c,statematrix{class},framenum,endframe,datamatrix{class});
                end
            end
        end
    end
end
end