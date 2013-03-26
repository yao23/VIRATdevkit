% Set up global variables used throughout the code

% directory for caching models, intermediate data, and results
cachedir = '~/voccache/';

% directory for LARGE temporary files created during training
tmpdir = '/var/tmp/voc/';

% dataset to use
dataset = '~/VIRAT_Video';

% directory with PASCAL VOC development kit and dataset
VOCdevkit = [ dataset '/VOCdevkit/'];

% which development kit is being used
% this does not need to be updated
VIRATdevkit = false;
TSUdevkit = false;
PSUdevkit = false;
switch dataset
  case '~/VIRAT_Video'
    VIRATdevkit=true;
  case '~/TSU_Experiment'
    VOCdevkit2007=true;
  case '~/PSU_Video'
    PSUdevkit=true;
end