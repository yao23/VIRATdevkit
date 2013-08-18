function datamatrix = final_object_tracker_cmodel(data,detdata,framedir,startframemat,visflag,outcsv_path,objectlist)

% Inputs Required :
% data - Background subtraction .hdf5 format file
% hbboxdata_od - Detection results
% videoobj - Original Video for which tracking has to be done
% statematrix - Stores the state of what all entities did
% startframe - Starting frame where detections are available
% endframe - frames till which tracking has to be done
% fb - forward or backward tracking
% visflag - Counter to pass to visualize the results or not
% cexplicit - tells whether to fill the between collision flag using linear
% interpolation or to just leave them as zeros
dbstop if error;
% States in statematrix include
% 1 - Entry
% 2 - Exit
% 3 - Tracked
% 4 - Last Detection
% 5 & higher - Under Collision

if isempty(data)
    bgswitch = 0;
else
    bgswitch = 1;
end

% Displaying nice color on detections
colorvec = ['r' 'g' 'b' 'k' 'r' 'g' 'b' 'k' 'r' 'g' 'b' 'k' 'r' 'g' 'b' 'k'...
    'r' 'g' 'b' 'k' 'r' 'g' 'b' 'k' 'r' 'g' 'b' 'k'];

% Initialization stuff goes here
[detectnum,currentscene,startframe,endframe,statematrix,datamatrix] = ...
    preprocess_tracking(detdata,startframemat);

% Tracking forward in video
fb = 1;

for framenum=startframe+fb:fb:endframe
    
    % Displaying if visflag is 1
    imname = sprintf('%06d.jpg',framenum-1);
    im = imread([framedir '/' imname]);
    if visflag
        hold off;
        imshow(im);
        hold on;
    end
    
    emptycells = cellfun('isempty',currentscene);
    % Checking if there is something in the scene
    %if ~(sum(emptycells)==length(currentscene))
    %% Checking current detections against current groups
    if bgswitch
        [statematrix,datamatrix] = group_detections(statematrix,framenum,...
            fb,datamatrix,detdata,framedir,data);
    end
    
    %% Assigning detections
    [statematrix,datamatrix,currentscene,detectnum] = assign_detections(...
        statematrix,framenum,fb,datamatrix,detdata,currentscene,detectnum);
    %% Doing tracking using background subtraction and optical flow
    
    % Tracking only if there is something to track
    for class = 1:length(datamatrix)
        if (length(find(statematrix{class}(framenum,:)>4))+length(find(statematrix{class}(framenum,:)==0)))>0
            [datamatrix,statematrix,currentscene] = track_detections(data,datamatrix,statematrix,framenum,framedir,currentscene,im,fb);
            % break;
            continue;
        end
    end
    
    %     else
    %         % What we need to do if there is nothing in the scene
    %         for class = 1:length(datamatrix)
    %             if length(find(detdata{class}(framenum,:))) >=2
    %                 % Novel unassigned detection, have to start a new track
    %                 currentdetectind = find(detdata{class}(framenum,:));
    %                 for i = 1:length(currentdetectind)/4
    %                     detectnum{class} = detectnum{class}+1;
    %                     currentscene{class} = [currentscene{class} detectnum{class}];
    %                     % Updating datamatrix
    %                     datamatrixnew = zeros(size(datamatrix{class},1),size(datamatrix{class},2)+4);
    %                     datamatrixnew(:,1:size(datamatrix{class},2)) = datamatrix{class};
    %                     datamatrix{class} = datamatrixnew;
    %                     datamatrix{class}(framenum,end-3:end) = detdata{class}(framenum,currentdetectind(4*(i-1)+1):currentdetectind(4*i));
    %                     % Updating statematrix
    %                     statematrixnew = zeros(size(statematrix{class},1),size(statematrix{class},2)+1);
    %                     statematrixnew(:,1:size(statematrix{class},2)) = statematrix{class};
    %                     statematrix{class} = statematrixnew;
    %                     statematrix{class}(1:framenum-fb,end) = ones(framenum-fb,1);
    %                     statematrix{class}(framenum,end) = 4;
    %                 end
    %             end
    %         end
    %     end
    
    % If the visualization flag is on
    if visflag
        for class = 1:length(datamatrix)
            for i = 1:size(datamatrix{class},2)/4
                currentbox = datamatrix{class}(framenum,1+(i-1)*4:4*i);
                if min(currentbox(3:4)) > 0
                    rectangle('Position',currentbox,'LineWidth',4,'EdgeColor',colorvec(class));
                end
            end
        end
        drawnow;
        %         f = getframe(gcf);
        %         imwrite(f.cdata, imname);
        %         close(gcf);
    end
    % Writing this data to a file
    for class = 1:length(datamatrix)
        fid = fopen([outcsv_path '/' num2str(objectlist{class}) '.csv'],'a+');
        track_class = datamatrix{class}(framenum,:);
        fprintf(fid,'%d,',framenum); 
        mystr = repmat('%4.2f,',1,length(track_class));
        fprintf(fid,mystr(1:end-1),track_class);
        fprintf(fid,'\n');
        fclose(fid);
    end
end

% if fb == -1
%     hbboxdata_od(endframe:startframe,1:size(datamatrix,2)) =...
%         datamatrix(endframe:startframe,:);
% else
%     hbboxdata_odnew = zeros(size(datamatrix,1),size(datamatrix,2));
%     hbboxdata_odnew(1:startframe,1:size(hbboxdata_od,2)) = hbboxdata_od(1:startframe,:);
%     hbboxdata_odnew(startframe:endframe,1:size(datamatrix,2)) =...
%         datamatrix(startframe:endframe,1:size(datamatrix,2));
%     hbboxdata_od = hbboxdata_odnew;
% end
