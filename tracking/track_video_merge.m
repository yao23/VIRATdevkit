function finaldata = track_video_merge(finaldata,datamatrix,objectlist,final_olist)
if ~isempty(objectlist)
    for class = 1:length(final_olist)
        ind = find(strcmp(final_olist{class},objectlist));
        if ~isempty(ind)
            % That means this class is present
            currdata = datamatrix{ind};
            % Appending this data to already existing tracking data
            if size(currdata,2)>size(finaldata{class},2)
                data = zeros(size(finaldata{class},1)+size(currdata,1),size(currdata,2));
                data(1:size(finaldata{class},1),1:size(finaldata{class},2))=finaldata{class};
                data(size(finaldata{class},1)+1:end,1:end) = currdata;
            elseif size(currdata,2)==size(finaldata{class},2)
                data = zeros(size(finaldata{class},1)+size(currdata,1),size(currdata,2));
                data(1:size(finaldata{class},1),1:size(finaldata{class},2))=finaldata{class};
                data(size(finaldata{class},1)+1:end,1:end) = currdata;
            else
                data = zeros(size(finaldata{class},1)+size(currdata,1),size(finaldata{class},2));
                data(1:size(finaldata{class},1),1:size(finaldata{class},2))=finaldata{class};
                data(size(finaldata{class},1)+1:end,1:size(currdata,2)) = currdata;
            end
            finaldata{class} = data;
        else
            % Updating the classes that didn't have any candidates
            data = zeros(size(finaldata{class},1)+size(datamatrix{1},1),size(finaldata{class},2));
            data(1:size(finaldata{class},1),1:end) = finaldata{class};
            finaldata{class} = data;
        end
    end
     
else
    % There was nothing in the current video
    for class = 1:length(final_olist)
        % Appeding zeros to data since there was really nothing in the data
        try
            currdata = finaldata{class};
        catch
            finaldata = cell(size(final_olist,1),size(final_olist,2));
            currdata = finaldata{class};
        end
        % If there was nothing before
        if isempty(currdata)
            finaldata{class} = zeros(size(datamatrix,1),4);
        else
            data = zeros(size(currdata,1)+size(datamatrix,1),size(currdata,2));
            data(1:size(currdata,1),1:end) = currdata;
            finaldata{class} = data;
        end
    end
end