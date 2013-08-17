import os
import random

import video

#random.seed(6)

data_dir = os.path.expanduser('~/data/mindseye/videos/')

def random_video(factor=4):
    '''Gets a random istare video filename'''
    ind = random.randrange(0, len(video_fnames))
    vid = video.asvideo(video_fnames[ind], factor)
    return vid

def get_video_path(fname_part):
    '''Return full path to a video given part of the file name, usually the ID'''
    for video_fname in video_fnames:
        if fname_part in video_fname:
            return video_fname
    raise IOError('Could not find a video name containing ' + fname_part)

def get_video(fname_part, factor=4, frames=None):
    '''Can specify all or part of the file name. Note that the video ID is the 
    first set of hex code in the file name. frames is a list of frames to get 
    with default to get all frames.'''
    return video.asvideo(get_video_path(fname_part), factor, frames)

def get_ID(path):
    '''Extracts the video ID from the video path or video name'''
    vid_fname = os.path.split(path)[1]
    return vid_fname.split('-')[0][-8:]

def get_longID(path):
    '''Returns the long ID of a video that is all but guaranteed to be 
    unique'''
    vid_fname = os.path.split(path)[1]
    return vid_fname.split('_')[-1][:36]

video_fnames = []
for root, dirs, files in os.walk(data_dir):
    video_fnames.extend([os.path.join(root, f) for f in files if f.endswith('.mov')])

# Check to make sure all short ID's are in fact unique i.e. have a one to one 
# correspondence with video filenames.
_IDs = dict()
for vid_path in video_fnames:
    ID = get_ID(vid_path)
    long_ID = get_longID(vid_path)

    # check that this short ID has not already been associated with a different 
    # long ID
    if ID in _IDs:
        assert _IDs[ID] == long_ID, 'Error non-unique video short ID detected. ' + ID + ': ' + long_ID
    else:
        _IDs[ID] = long_ID

del _IDs
