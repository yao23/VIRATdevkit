function rawbbdata = merge_time_tracks(pre_datamatrix,pre_statematrix,pre_objectlist,rawbbdata,oname)
% This function will merge tracks from previous time segment to current

% Finding current object class corresponding to oname
match = strcmp(pre_objectlist,oname(3:end-3));
ind = find(match);
if ~isempty(ind)
    % Appending the last few detections to the data
    
    % Finding the data of the data
    statelast = pre_statematrix{ind}(end,:);
    detdatalast = pre_datamatrix{ind}(end,:);
    
    dind = find((statelast==3)+(statelast==4));
    for i = 1:length(dind)
        % Detection for current class
        currdet = detdatalast((dind-1)*4+1:dind*4);
        newraw = zeros(size(rawbbdata,1)+4,size(rawbbdata,2));
        newraw(1:size(rawbbdata,1),1:size(rawbbdata,2)) =  rawbbdata;
        newraw(size(rawbbdata,1)+1:size(rawbbdata,1)+4) = [currdet(1:2),currdet(1:2)+currdet(3:4)];
        rawbbdata = newraw;
    end
end
end