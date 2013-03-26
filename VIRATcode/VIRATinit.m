clear VIRATopts

% use VIRAT video dataset release 1.0

VIRAT_R1=true; % set true to use VIRAT Release 1.0 data

% dataset

if VIRAT_R1
    VIRATopts.dataset='VIRAT_Video';
else
    VIRATopts.dataset='TSU_Experiments';
end

% get current directory with forward slashes

cwd=cd;
cwd(cwd=='\')='/';

% change this path to point to your copy of the PASCAL VOC data
VIRATopts.datadir=[cwd '/'];

% change this path to a writable directory for your results
VIRATopts.resdir=[cwd '/results/' VIRATopts.dataset '/'];

% change this path to a writable local directory for the example code
VIRATopts.localdir=[cwd '/local/' VIRATopts.dataset '/'];

% initialize the test set

VIRATopts.testset='val'; % use validation data for development test set
% VOCopts.testset='test'; % use test set for final challenge

% initialize main challenge paths

VIRATopts.annopath=[VIRATopts.datadir VIRATopts.dataset '/Annotations/%s.txt'];
VIRATopts.imgpath=[VIRATopts.datadir VIRATopts.dataset '/JPEGImages/%s.jpg'];
VIRATopts.imgsetpath=[VIRATopts.datadir VIRATopts.dataset '/ImageSets/Main/%s.txt'];
VIRATopts.clsimgsetpath=[VIRATopts.datadir VIRATopts.dataset '/ImageSets/Main/%s_%s.txt'];
VIRATopts.clsrespath=[VIRATopts.resdir 'Main/%s_cls_' VIRATopts.testset '_%s.txt'];
VIRATopts.detrespath=[VIRATopts.resdir 'Main/%s_det_' VIRATopts.testset '_%s.txt'];

% ????? is it necessary to have these segmentation part
% initialize segmentation task paths

VIRATopts.seg.clsimgpath=[VIRATopts.datadir VIRATopts.dataset '/SegmentationClass/%s.png'];
VIRATopts.seg.instimgpath=[VIRATopts.datadir VIRATopts.dataset '/SegmentationObject/%s.png'];

VIRATopts.seg.imgsetpath=[VIRATopts.datadir VIRATopts.dataset '/ImageSets/Segmentation/%s.txt'];

VIRATopts.seg.clsresdir=[VIRATopts.resdir 'Segmentation/%s_%s_cls'];
VIRATopts.seg.instresdir=[VIRATopts.resdir 'Segmentation/%s_%s_inst'];
VIRATopts.seg.clsrespath=[VIRATopts.seg.clsresdir '/%s.png'];
VIRATopts.seg.instrespath=[VIRATopts.seg.instresdir '/%s.png'];

% initialize layout task paths

VIRATopts.layout.imgsetpath=[VIRATopts.datadir VIRATopts.dataset '/ImageSets/Layout/%s.txt'];
VIRATopts.layout.respath=[VIRATopts.resdir 'Layout/%s_layout_' VIRATopts.testset '_%s.xml'];

% initialize the VOC challenge options
VIRATopts.classes={...
        'bicycle'
        'bus'
        'car'
        'motorbike'
        'person'};

VIRATopts.nclasses=length(VIRATopts.classes);	

VIRATopts.poses={...
    'Unspecified'
    'SideFaceLeft'
    'SideFaceRight'
    'Frontal'
    'Rear'};

VIRATopts.nposes=length(VIRATopts.poses);

VIRATopts.parts={...
    'head'
    'hand'
    'foot'};    

VIRATopts.maxparts=[1 2 2];   % max of each of above parts

VIRATopts.nparts=length(VIRATopts.parts);

VIRATopts.minoverlap=0.5;

% initialize example options

VIRATopts.exannocachepath=[VIRATopts.localdir '%s_anno.mat'];

VIRATopts.exfdpath=[VIRATopts.localdir '%s_fd.mat'];
