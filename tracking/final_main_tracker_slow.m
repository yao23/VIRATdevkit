function [] = final_main_tracker_slow(framedir, csvfile, outcsv_path, bgswitch, video_name)
% Purpose : Do tracking using optical flow given certain detections
% Authors : Suren Kumar
% Last Update : August 9th,2012
% To do : None
%dbstop if error;
% Description of inputs
% input_dir is the directory where %06d.ppm files are present
% csvfile is the complete path to detection file
% outcsv_path is the path where output csv file should be written
% bgswitch is whether to evaluate background subtraction


% Adding path for optical flow
addpath('./opticalflow');
bgswitch = str2double(bgswitch);

% Visualization Flag to demonstrate results overlaid and make video
visflag = 1;

% Raw detection data read
rawbbdata = csvread(csvfile);
rawbbdata = sparse2dense(rawbbdata);
% Separating the data required for tracking particular class
reqdata = rawbbdata(:,1:5:end);
classids = unique(reqdata);
% Seperating class data for each class from raw detections
% Stores list of objects present in current video
objectlist = {};
% Stores detection data of all the objects
detdata = {};
% Stores starting frame for each object class
startframemat = {};

if find(classids(:)==0)
   classids = classids(2:end);
end

% Forming detected bounding box for current class
for class = 1:length(classids)
    [hbboxdata_od,status,startframe] = process_detections_slow(rawbbdata,classids(class));
    if status==0
        objectlist = [objectlist;classids(class)];
        detdata{size(objectlist,1)} = hbboxdata_od;
        startframemat{size(objectlist,1)} = startframe;
    end
end


% Further processing only if there is atleast one true positive detection
if ~isempty(objectlist)
    
    % Processing for opticalflow
    if bgswitch
        % video_name = sprintf('%06d.jpg', startframe);
        % Processing for background subtraction
        data = bgsubtract(video_name, framedir, outcsv_path);
    end
    
    % Main Control Loop
    if bgswitch
        datamatrix = final_object_tracker_cmodel(data,detdata,framedir,...
            startframemat,visflag,outcsv_path,objectlist);
    else
        datamatrix = final_object_tracker_cmodel([],detdata,framedir,...
            startframemat,visflag,outcsv_path,objectlist);
    end
    % Currently  hbboxdata_od is in x y w h format, for output
end


