% For preprocessing before tracking starts
function [detectnum,currentscene,startframe,endframe,statematrix,datamatrix] = ...
    preprocess_tracking(detdata,startframemat)
% Finding the startframe to begin with
[startframe,oind] = min(cell2mat(startframemat));
% Detections in the starting frame
sfdata = detdata{oind}(startframe,:);
ind = find(sfdata(3:4:end));
endframe = size(detdata{1},1);
% Storing State
statematrix = cell(1,size(detdata,2));
% Storing Detection Data
datamatrix = cell(1,size(detdata,2));


% Number of person in the scene to assign person number
detectnum = cell(1,size(detdata,2));
% Intialize detectnum cell array
[detectnum{:}] = deal(zeros(1));
% Intializing currentscene
currentscene = cell(1,size(detdata,2));

% Initializing each entry to the statematrix
for i = 1:size(detdata,2)
    if i==oind
         % Perform detection overlap removal so that we only have one
         % detection for overlapping detection
        if length(ind)>1
           % More than one detection 
            ind = detections_nms(sfdata,ind);
        end 
        statematrix{i} = zeros(endframe,length(ind));
        statematrix{i}(startframe,:) = 4*ones(1,length(ind));
        datamatrix{i} = zeros(endframe,length(ind)*4);
        for j = 1:length(ind)
            detectnum{i} = detectnum{i}+1;
            currentscene{i} = detectnum;
            datamatrix{i}(startframe,(j-1)*4+1:j*4) = detdata{i}(startframe,(ind(j)-1)*4+1:ind(j)*4);
        end
    else
        %statematrix{i} = zeros(endframe,length(ind));
        detind = find(detdata{i}(startframemat{i},3:4:end));
        if length(detind)>1
           % More than one detection 
            ind = detections_nms(sfdata,ind);
        end 
        datamatrix{i} = zeros(endframe,length(detind)*4);
        statematrix{i} = zeros(endframe,length(detind));
        for k = 1:length(detind)
            datamatrix{i}(startframemat{i},(k-1)*4+1:k*4) = detdata{i}(startframemat{i},...
-                (detind(k)-1)*4+1:detind(k)*4);
        end
        statematrix{i}(startframemat{i},:) = 4*ones(1,length(detind));
    end
end
end
