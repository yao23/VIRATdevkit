% Visualizing Background Subtraction
clc;clear all;close all;
% videofilename = 'GPTC_20110822_CR_10_CP1_AVOIDBADGUY.mp4';
videofilename = 'Collide3_A1_C1_Act1_3_PARK1_MC_AFTN_DARK_47cee9d4-c5af-11df-b9d5-e80688cb869a.mov';
bgdirectory = '/big2t/istareproject/object-tracking/evaluations_tracker/bgdata';
imgwritedir = '/home/surenkum/DARPA_DATA/background-subtraction/C-D2a/images';

silresolution = 1;

% Reading Silhouette Data
datafilename = [bgdirectory '/' videofilename(1:end-4) '.hdf5'];
fileID = H5F.open(datafilename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
datasetID = H5D.open(fileID, 'output_array');

% Get dataspace
dataspaceID = H5D.get_space(datasetID);
[rank dims] = H5S.get_simple_extent_dims(dataspaceID);

% For latest hdf5 format of silhouette data provided by Signal Unit
framesize = [dims(3), dims(2)];
maxframe = dims(1)-4;
endframe = maxframe;

% Select hyperslab of data
start = [0 0 0 0];
stride = [];
count = [dims(1) dims(2) dims(3) dims(4)]; % Size of data to be read
block = [];
H5S.select_hyperslab(dataspaceID, 'H5S_SELECT_SET', ...
    start, stride, count, block);

% Define the memory dataspace.
memspaceID = H5S.create_simple(rank, count, []);

% Read the subsetted data
data = H5D.read(datasetID, 'H5ML_DEFAULT', ...
    memspaceID, dataspaceID, 'H5P_DEFAULT');

H5D.close(datasetID);
H5F.close(fileID);

for framenum = 1:maxframe
    frame = permute(data(:,:,:,framenum),[4 2 3 1]);
    frame = permute(frame,[3 2 1]);
    frame = double(frame*255);
    imshow(frame);
    pause(0.025);
%     imwrite(frame,sprintf('%s/img%05d.png',imgwritedir,framenum),'png');
end
