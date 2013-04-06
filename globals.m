% Set up global variables used throughout the code

% directory for caching models, intermediate data, and results

cachedir = '~/Projects/object_detection/tools/VIRATdevkit/viratcache/';
cachedir = './viratcache/';

% directory for LARGE temporary files created during training
tmpdir = '~/Projects/object_detection/tools/VIRATdevkit/var/tmp/virat/';
tmpdir = './var/tmp/virat/';

% dataset to use
dataset = '.';

% directory with VIRAT development kit and dataset
VIRATdevkit = dataset;

% which development kit is being used
% this does not need to be updated
% VIRATdevkit = false;
% TSUdevkit = false;
% PSUdevkit = false;
% switch dataset
%   case '.'
%     VIRATdevkit=true;
%   case '~/TSU_Experiment'
%     TSUdevkit=true;
%   case '~/PSU_Video'
%     PSUdevkit=true;
% end