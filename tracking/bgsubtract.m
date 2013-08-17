function data = bgsubtract(videofilename,viddirectory,sildirectory)
% Current directory with repsect to which various paths are located
dsample = 2;
codedir = [cd '/process_video.py'];
% Setting environment variable of matlab
setenv('HDF5_DISABLE_VERSION_CHECK','2');
% unix(['python ' codedir ' ' [viddirectory '/' videofilename] ' '...
%     sildirectory ' ' num2str(dsample)]);
% Reading Silhouette Data
datafilename = [sildirectory '/' videofilename(1:end-4) '.hdf5'];
fileID = H5F.open(datafilename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
datasetID = H5D.open(fileID, 'output_array');

% Get dataspace
dataspaceID = H5D.get_space(datasetID);
[rank dims] = H5S.get_simple_extent_dims(dataspaceID);

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
end