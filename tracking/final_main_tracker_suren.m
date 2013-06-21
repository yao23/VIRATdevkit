function [] = final_main_tracker(vidlistfilename,vidlistdir,viddir,sviddir,bboxdirectory,...
    outdatadir,framedir,inpframedir,outframedir,sildir)
% Purpose : Do tracking using optical flow given certain detections
% Authors : Suren Kumar
% Last Update : June 25,2012
% To do : None

% Adding path for optical flow
addpath('./opticalflow');

% Visualization Flag to demonstrate results overlaid and make video
visflag = 0;

% Input filename text file - it contains all the videofile names
%vidlistfilename = 'videolist.txt';
% Directory where this file is located
%vidlistdir = '/big2t/istareproject/detection_cuda/trackdense';
vidlistfile = [vidlistdir '/' vidlistfilename];

% Breaking down the video duration in secs
samplesec = 30;

% Model class that we are interested in tracking
classid = 1; % For tracking person

% Reading video list
fid = fopen(vidlistfile);
vidlist = textscan(fid,'%s');
fclose(fid);

for filenum=1:length(vidlist{1})
    
    % Reading filename of current video
    videofilename = vidlist{1}{filenum};
    
    % Cutting current video into segments
    cmd = ['ffmpeg -i ' viddir '/' videofilename ' 2>&1 |grep "Duration"'];
    s = evalc(['system(''' cmd '''' ')']);
    % Calculating total time of this long video
    ttime = str2double(s(16:17))*60+str2double(s(19:20));
    % Removing previous videoparts from sampled video director
    system(['rm -r ' sviddir '/*.mov']);
    % Storing the finally stored datamatrix
    final_data = {};
    % Final list of object data
    final_olist = {};
    % Pre object list
    pre_objectlist = {};
    
    for vlist = 0:(ttime/samplesec-1)
        
        system(['ffmpeg -i ' viddir '/' videofilename ' -sameq -ss 00:' sprintf('%02d',(vlist-rem(vlist,2))/2)...
            ':' sprintf('%02d',rem(vlist,2)*30) ' -t 00:00:' num2str(samplesec) ' '...
            sviddir '/videopart' num2str(vlist+1) '.mov']);
        
        % Stores list of objects present in current video
        objectlist = {};
        % Stores detection data of all the objects
        detdata = {};
        % Stores starting frame for each object class
        startframemat = {};
        pvidfilename = ['videopart' num2str(vlist+1) '.mov'];
        % Cleanup before detector runs
        % Remove previous .csv with the same name
        system(['rm ' bboxdirectory '/detection_' pvidfilename '.csv']);
        % Remove previous frames from inpframedir
        system(['rm -r ' inpframedir '/*.ppm'])
        % Remove detected frames
        system(['rm -r ' outframedir '/*.ppm' ])
        
        % Reading the object list for what objects need to be tracked
        fid = fopen('objects.txt');
        s = textscan(fid,'%d %s %s %f');
        fclose(fid);
        
        % Creating the standard final object list
        if isempty(final_olist)
        for i = 1:length(s{1})
            tmpo = cell2str(s{2}(i));
            final_olist = [final_olist,tmpo(3:end-3)];
        end
        end
        
        for olist = 1:length(s{1})
            
            % Removing the previous modelfile.txt
            system('rm -r modelfile.txt');
            fid = fopen('modelfile.txt','w+');
            object = cell2str(s{3}(olist));
            fprintf(fid,'%s\n',object(3:end-3));
            fclose(fid);
            detectionthresh = s{4}(olist);
            % Running detector for current video
            system(['rm ' bboxdirectory '/detection_' pvidfilename '.csv']);
            system(['./cudafelz_example ' sviddir '/' pvidfilename ' ' num2str(detectionthresh) ' '...
                inpframedir ' ' outframedir ' ' bboxdirectory]);
            oname = cell2str(s{2}(olist));
            system(['mv ' bboxdirectory '/detection_' pvidfilename '.csv '...
                bboxdirectory '/detection_' pvidfilename '_' oname(3:end-3) '.csv']);
            % Raw detection data read
            rawbbdata = csvread([bboxdirectory '/' 'detection_' pvidfilename '_' oname(3:end-3) '.csv']);
            % Seperating the data required for tracking particular class
            
            % Adding the data from previous object class
            if ~isempty(pre_objectlist)
                rawbbdata = merge_time_tracks(pre_datamatrix,pre_statematrix,pre_objectlist,rawbbdata,oname);
            end
            
            reqdata = rawbbdata(:,1:5:end);
            reqinddata = zeros(size(rawbbdata,1),1);
            for i = 1:size(rawbbdata,1)
                reqinddata(i) = length(find(reqdata(i,:) == classid));
            end
            maxdetclass = max(reqinddata);
            % Forming detected bounding box for current class
            if maxdetclass>0
                [hbboxdata_od,status,startframe] = process_detections(rawbbdata,maxdetclass,reqinddata,reqdata);
                if status==1
                    objectlist = [objectlist;oname(3:end-3)];
                    detdata{size(objectlist,1)} = hbboxdata_od;
                    startframemat{size(objectlist,1)} = startframe;
                end
            end
        end
        
        % Further processing only if there is atleast one true positive detection
        if ~isempty(objectlist)
            
            % Processing for opticalflow
            % Removing any previous frame in the original frame directory
            system(['rm -r ' framedir '/*.png']);
            % Extracting frames of original size
            system(['ffmpeg -i ' sviddir '/' pvidfilename ' ' framedir '/frame_%05d.png']);
            % Processing for background subtraction
            data = bgsubtract(pvidfilename,sviddir,sildir);
            
            % Main Control Loop
            clc;
            fprintf('Video Number %d \n',filenum);
            [datamatrix,statematrix] = final_object_tracker_cmodel(data,detdata,framedir,startframemat,visflag);
            % Currently  hbboxdata_od is in x y w h format, for output
            
            % Fuse this data to the final data
            final_data = track_video_merge(final_data,datamatrix,objectlist,final_olist);
            % Saving this data for future use
            pre_datamatrix = datamatrix;
            pre_statematrix = statematrix;
            pre_objectlist = objectlist;
        else
            % There was nothing in the video
            final_data = track_video_merge(final_data,rawbbdata,objectlist,final_olist);
            pre_datamatrix = {zeros(size(rawbbdata,1),4)};
            pre_statematrix = {zeros(size(rawbbdata,1),1)};
            pre_objectlist ={};
        end
    end
    % Writing this tracked data to file
    for i = 1:length(final_data)
       csvwrite([outdatadir '/' videofilename(1:end-4) '_' final_olist{i} '.csv',final_data{i}]);        
    end
end

