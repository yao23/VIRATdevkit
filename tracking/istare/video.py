'''Useful functions for operating on videos, all functions should accept Video objects.

Author: Julian Ryde
 Jason Corso
'''

# standard modules
import os
import tempfile

# numeric/scientific modules
import cv
import numpy as np
import numpy # needed for dtype eval line in _load_memmap
import scipy as sp
import scipy.ndimage as ndimage
import pylab
import matplotlib

# istare modules
import myimage
import video_visualiser
import subprocess as subp

cv_cap = 'CV_CAP_PROP_'

file_ext = '.memmap'
image_ext = '.bmp'

def _get_cv_cap_props():
    '''Returns a list of the cv capture attributes'''
    attributes = dir(cv)
    attributes = [att for att in attributes if att.startswith(cv_cap)]
    return attributes

def get_properties(capture):
    '''Get a dictionary of properties for this capture'''
    properties = {}
    for att in _get_cv_cap_props():
        val = cv.GetCaptureProperty(capture, getattr(cv, att))
        properties[att[len(cv_cap):]] = val
    return properties

def _im_to_arr(im, resized_im):
    # if necessary perform resizing
    if resized_im is not None:
        cv.Resize(im, resized_im, cv.CV_INTER_AREA)
        #AREA CUBIC LINEAR NN
        im = resized_im
    arr = image_array(im) 
    return arr.copy()

def float_to_uint8(X):
    '''Quantises an array with values 0 to 1 inclusive to bins 0 to 255 
    inclusive'''
    inds_one = X == 1
    A = np.uint8(X*256) # floor operation
    A[inds_one] = 255  # handle edge case where X == 1 goes to 256
    return A

def asvideo(video_source, factor=1, maxcols=None):
    '''Creates a Video object from a range of sources. These can be a video 
    file name or an nd array.
    
     The following arguments are only applied if the video_source is a file path on disk. 
     factor allows for downsizing the video by a constant factor.  Default is no downsizing.
     maxcols allows for downsizing the video such that the columns are a maximum size. If the video 
              columns number is already less than maxcols, then no downsizing occurs.  The aspect ratio of
              the video is maintained.
             maxcols is applied *after* the factor
    '''

    # if video_source is ndarray like wrap the array and return video object
    if hasattr(video_source, 'shape') and hasattr(video_source, 'dtype'):
        if len(video_source.shape) == 3:
            video_source.shape = video_source.shape + (1,)

        vshape = video_source.shape
        vdtype = video_source.dtype
        vid = Video(frames=vshape[0], rows=vshape[1], columns=vshape[2], bands=vshape[3], dtype=vdtype, initialise=False)
        vid.V = video_source
        return vid

    if not os.path.exists(video_source):
        raise IOError(video_source + ' not found')

    '''
    capture = cv.CaptureFromFile(video_source)
    props = get_properties(capture) 
    width = int(props['FRAME_WIDTH'])
    height = int(props['FRAME_HEIGHT'])

    #self.fname = fname
    #self._cap_prop_names = _get_cv_cap_props()
    #self._props = self.get_properties()
    #self._resized_im = None
    #self._first_frame = self.next_frame()
    # reset back to beginning of video

    first_frame = cv.QueryFrame(capture)

    # setup the resize image buffer 
    resized_im = None
    if factor != 1:
        factor = int(factor)
        width /= factor
        height /= factor
        resized_im = cv.CreateImage((width, height), first_frame.depth, first_frame.channels)

    frames = []

    # Add the first video frame to list of video frames
    arr = _im_to_arr(first_frame, resized_im)
    frames.append(arr)

    print 'Converting video to array'
    while True:
        frame = cv.QueryFrame(capture)
        if frame is None:
            break
        arr = _im_to_arr(frame, resized_im)

        frames.append(arr)

    # assign list of frames to array
    frame_count = len(frames)
    vshape = (height, width, first_frame.channels, frame_count)
    # TODO decide on new ordering?
    #vshape = (frame_count, first_frame.channels, height, width)
    '''
    (unusedfh,sample_filename) = tempfile.mkstemp()
    cmd = 'ffmpeg -i "' + video_source + '" -vframes 1 ' + sample_filename+'%d' + image_ext + ' 2> /dev/null > /dev/null'
    sample_filename = sample_filename + '1' + image_ext
    subp.call(cmd, shell = True)
    sample_img = sp.misc.imread(sample_filename)
    (height, width, channels) = sample_img.shape
    if factor != 1:
        height = int(height/factor)
        width = int(width/factor)

    if (not maxcols is None) and width > maxcols:
        t = float(maxcols)/float(width)
        width = int(t*width)
        height = int(t*height)

    # ffmpeg is currently still only using a single core for this
    dirname = tempfile.mkdtemp()
    noof_threads = 2
    ffmpeg_options = ' -threads %d -s %dx%d -sws_flags %s ' % (noof_threads, width, height, 'bicubic')
    # TODO cannot process videos longer than 9999999 frames
    cmd = 'ffmpeg -i "' + video_source + '"' + ffmpeg_options + dirname + '/frames%07d' + image_ext + ' 2> /dev/null > /dev/null'
    subp.call('mkdir -p ' + dirname, shell = True)
    print 'Executing:', cmd
    subp.call(cmd, shell = True)
    print 'ffmpeg finished'

    frame_names = os.listdir(dirname)
    frame_names.sort()
    frame_count = len(frame_names)
    
    vid = Video(frames=frame_count, rows=height, columns=width, bands=channels, dtype=np.uint8)
    for i, fname in enumerate(frame_names): 
        fullpath = os.path.join(dirname, fname)
        img_array = sp.misc.imread(fullpath)

        # comes in as floats (0 to 1 inclusive) from a png file, not necesary for bmp file
        # img_array = float_to_uint8(img_array)

        vid.V[i, ...] = img_array
        # delete temporary files
        os.remove(fullpath)

    vid.source = video_source
    #vid.temp_fname = temp_fname
    os.rmdir(dirname)
    os.remove(sample_filename)
    return vid

def load_images(dirpath):
    if not os.path.exists(dirpath):
        raise IOError(dirpath + ' not found')
    filenames = os.listdir(dirpath)
    filenames.sort() 
    if filenames == []:
        print dirpath, ' is empty'
        return
    sample_img = sp.misc.imread(os.path.join(dirpath, filenames[0]))
    shape = sample_img.shape 
    vid = Video(frames=len(filenames), rows=shape[0], columns=shape[1], bands=shape[2], dtype=np.uint8)
    for i, fname in enumerate(filenames):
        fullpath = os.path.join(dirpath, fname)
        vid.V[i, ...] = sp.misc.imread(fullpath)
    return vid

def _load_memmap(fname, mode='r+'):
    '''Similar to numpy memmap but loads the shape and dtype information that was saved alongside the binary file.'''
    info_file = open(fname + file_ext)
    props = eval(info_file.read())
    dtype = eval(props['dtype'])
    V = np.memmap(fname, dtype=dtype, mode=mode, shape=props['shape'])
    return V

# TODO this should be a method on video object
def thumbnails(Vs, n=5, scale_colour=True, return_positions=False):
    '''Takes a 4 dimensional video array and generates an array consisting of n 
    thumbnails in a row.  Essential converts the video into a comic strip.'''
    # TODO enable thumbnails for a list of videos similar to play array
    # TODO assert they are all the same length?

    if isinstance(Vs, numpy.ndarray):
        Vs = [Vs] # make it a list with a single item
    thumbs = []
    for V in Vs:
        inds = np.linspace(0, V.shape[0], n, endpoint=False).astype(int)
        frames = []
        for ind in inds: 
            frames.append(V[ ind,:,:,:])
        if scale_colour:
            thumbs.append(myimage.scale_image(np.hstack(frames)))
        else:
            thumbs.append(np.hstack(frames))
    if return_positions:
        return np.vstack(thumbs), inds
    else:
        return np.vstack(thumbs)

def play(vids, titles=None, rescale=False, loop=False):
    '''Plays a number of videos synchronously'''

    # Test whether we are dealing with a single video or an iterable of videos
    if isinstance(vids, Video):
        vids = [vids, ] # make it a list with a single item

    interpol = 'nearest'

    # Set up the figures
    pylab.ion()
    figs = []
    for i, vid in enumerate(vids):
        is_bool = (vid.V.dtype == bool)
        is_grey = (vid.bands == 1) and not is_bool

        pylab.figure(i)
        pylab.clf()
        if titles is not None:
            pylab.title(titles[i])
        pylab.subplots_adjust(left=0, right=1, bottom=0, top=1)
        first_im = np.squeeze(vid.V[0,...])
        if rescale:
          vmin=vid.V.min()
          vmax=vid.V.max()
        else:
          vmin=0
          vmax=255
        if is_grey:
            fig = pylab.imshow(first_im, matplotlib.cm.gray, interpolation=interpol, vmin=vmin, vmax=vmax) 
        elif is_bool:
            fig = pylab.imshow(first_im, interpolation=interpol, vmin=0, vmax=1)
        else:
            fig = pylab.imshow(first_im, interpolation=interpol,vmin=vmin, vmax=vmax)
        figs.append(fig)

    # TODO assert that all the arrays have the same number of frames
    
    pylab.ioff()
    while True:
        for i in range(len(vid)): # iterate through frames
            for j, vid in enumerate(vids):
                X = np.squeeze(vid.V[i,...])
                fig = figs[j]
                fig.set_data(X)
                pylab.figure(j)
                pylab.draw()
        if not loop:
            break

# TODO refactor merge resize with save_array
def resize(fname, out_fname, factor):
    '''Resizes a video file down by factor'''
    vid = Video(fname)
    vid.downsample(factor)
    props = vid.get_properties()
    fps = props['FPS']
    fmt = cv.CV_FOURCC('M', 'J', 'P', 'G')
    #fmt = -1 # default codec?
    writer = cv.CreateVideoWriter(out_fname, fmt, fps, (vid.width, vid.height))
    for frame in vid.frames():
        cv.WriteFrame(writer, frame)

def image_array(frame):
    # TODO do the conversion properly with code on this web page
    # http://opencv.willowgarage.com/documentation/python/cookbook.html
    frame_arr = np.asarray(cv.GetMat(frame))

    if frame_arr.ndim == 3:
        frame_arr = frame_arr[:, :, ::-1] # reverse RGB
    else:
        frame_arr.shape = frame_arr.shape[0], frame_arr.shape[1], 1
    return frame_arr

# TODO currently nobody is using this
def array_framediff(V, fname):
    oldI = V[0,:,:,:].astype(int)

    # Does not use framediff to avoid casting the same section of V twice
    D = _create_memmap(V.shape)
    for i in range(1, V.shape[3]):
        I = V[i,:,:,:].astype(int)
        D[:,:,:,i] = np.uint8(np.abs(I - oldI))
        oldI = I
    return D

def _colour_map(im, vmax):
    '''Colour maps a 2D array that is not 3 channel uint8'''
    im = np.float32(im.squeeze())
    # TODO scaling to handle negatives
    im /= vmax
    return pylab.cm.jet(im, bytes=True)[..., :-1] # remove alpha channel

# TODO vid.absdiff(vid2)
# TODO im.absdiff(im2)
def absdiff(V1, V2):
    '''Handles the problem with subtracting unsigned integer arrays'''
    # TODO maybe use framediff, but be
    assert V1.shape == V2.shape
    D = np.empty(V1.shape, dtype=np.uint8)
    # frame by frame to conserve memory
    for i in range(V1.shape[3]):
        #D[:,:,:,i] = myimage.framediff(V1[:,:,:,i], V2[:,:,:,i])
        D[:,:,:,i] = np.abs(V1[:,:,:,i].astype(np.int) - V2[:,:,:,i].astype(np.int))

    return np.abs(D)

# TODO iterable over frames e.g. vid[0] is zeroth frame
class Video:
    '''
    vid.V[0,1,2,3] for row 1 col 2 in colour band 3 for frame 0.

    The image convention of row, column, band follows same convention as 
    imshow, imread.

    vid[0] returns the first frame of the video as an image object
    vid.V[0] returns the first frame of the video as an ndarray

    instantiate from both a file and an array

    TODO: Video should have a way to get its dtype without going to its store to get it.
           vid.dtype rather than vid.V.dtype  (for encapsulation)
    '''

    XD = 2  # X dimension
    YD = 1  # Y dimension
    BD = 3  # Band dimension
    TD = 0  # Temporal dimension

    def __init__(self, frames, rows, columns, bands, dtype=np.uint8, initialise=True):
        mode = 'w+'
        memmap_fname = tempfile.mktemp(prefix='video_bin_')
        self._memmap_fname = memmap_fname

        vshape = frames, rows, columns, bands

        if initialise:
            self.V = np.memmap(memmap_fname, dtype=dtype, mode=mode, shape=vshape)
        self.frames = frames
        self.rows = rows
        self.columns = columns
        self.bands = bands

    def __getitem__(self, i):
        return self.V[i, ...]

    def __len__(self):
        return self.V.shape[0]

    def __del__(self):
        if (os.path.exists(self._memmap_fname)):
            os.remove(self._memmap_fname)

    def __eq__(self, vid):
        # TODO check other attributes as well
        return np.alltrue(self.V == vid.V)

    def copy(self):
        '''Make a copy of the video.'''
        vid = Video(self.frames,self.rows,self.columns,self.bands,self.V.dtype, initialise=False)
        vid.V = self.V.copy()
        return vid 

    def display(self,rescale=None, loop=False):
        '''Plays the video.  Called display so that the method name can be the 
        same for images.'''
        if rescale is None:
            # default rescale to not rescale if it is np.uint8 otherwise do 
            # rescale
            rescale = self.V.dtype != np.uint8
        play(self, rescale=rescale, loop=loop)

    def difference_of_gaussians(self, sigma1, sigma2):
        fV = np.float32(self.V)
        G1 = ndimage.gaussian_filter(fV, sigma=sigma1, order=0)
        G2 = ndimage.gaussian_filter(fV, sigma=sigma2, order=0)
        return asvideo(G1 - G2)

    def filter_DoG(self, sigma):
        '''Compute the Difference of a Gaussian (DoG) on a video array.
           The Video array can be 3D or 4D, just set the sigma appropriately.
           So to get the spatial derivative of each frame sigma=(0, 5, 5, 0)
           and to get the time derivative of each pixel sigma=(5, 0, 0, 0). 
           Note the output video is grayscale and float32.
           sigma is the variance of the Gaussian filter.

           NOTE: does no scaling.
        '''
        # todo should it convert colour video automatically?
        #assert self.bands == 1, 'only applicable to grayscale video'
        #M = ndimage.gaussian_filter1d(np.float32(self.V), sigma=sigma, axis=axis, order=1)
        M = ndimage.gaussian_filter(np.float32(self.V), sigma=sigma, order=1)
        return asvideo(M)

    def rgb2gray(self):
        '''Convert the RGB video into a grayscale version.
           Note the output array is a 3D array
           fname is the filename to the memory map that can be created for the
            output video

           TODO: Check on the ordering of the bands in the video.
           The coefficients from rgb2gray should be
           R 0.2989
           G 0.5870
           B 0.1140

           TODO: support output video to have matching dtype as input video

           NOTE: Requires full storage of the video in memory
        '''
        G = np.asarray( (0.1140, 0.5870, 0.2989) )
        foo = np.tensordot(self.V,G,axes=(3,0))
        foo.shape = foo.shape +  (1,)
        return asvideo(np.uint8(foo))

    # TODO overlap between resize and save_array?
    def save(self,fname):
        '''Save the Video object as a video file, mpg
        '''
        #writer = cv.CreateVideoWriter(fname,cv.CV_FOURCC('M', 'J', 'P', 'G'),30,(self.V.shape[Video.XD],self.V.shape[Video.YD]))
        '''
        writer = cv.CreateVideoWriter(fname,cv.CV_FOURCC('D', 'I', 'V', '3'),30,(self.V.shape[Video.XD],self.V.shape[Video.YD]))

        if(self.V.shape[Video.BD] == 1):
            temp_img = cv.CreateImage((self.V.shape[Video.XD],self.V.shape[Video.YD]), 8 ,3)
            for i in range(self.V.shape[Video.TD]):
                tempIplImg = myimage.array_image_test(self.V[i,:,:,:])
                cv.CvtColor(tempIplImg, temp_img, cv.CV_GRAY2BGR)
                cv.WriteFrame(writer,temp_img)
        else:
            for i in range(self.V.shape[Video.TD]):
                tempIplImg = myimage.array_image_test(self.V[i,:,:,::-1])
                # ::-1 to reverse colour order Reverse colours
                cv.WriteFrame(writer,tempIplImg)
        '''
        # Using ffmpeg to save the video
        temp_dir = tempfile.mkdtemp()
        self.save_images(temp_dir)
        cmd = 'ffmpeg -i ' + temp_dir+'/%05d.png ' + '-r 30 ' + fname  
        subp.call(cmd, shell = True)
        cmd = 'rm -r ' + temp_dir
        subp.call(cmd, shell = True)

    def scale_DLogistic(self,steepness):
        '''  Scale the video with a double logistic of steepness.
          Double Logistic Definition (bottom):
               http://en.wikipedia.org/wiki/Logistic_function

          Use a double logistic to normalize the 1-band video array in Va and 
          then rescale output to the 0:1 range

          Some asserts that are required.
          1. Video is float32 already

          TODO: Inplace operation should be supported.  But, the sp.sign and 
          sp.exp don't seem to allow out= keywords even though their doc says 
          they do.
        '''

        assert(self.V.dtype == sp.float32)
        Va = self.V
        Va = sp.sign(Va) * (1.0-sp.exp( - (Va / steepness)*(Va / steepness) ))
        Va = (Va+1.0)/2.0

        return asvideo(Va)

    def visualise(self):
        '''Displays an interactive viewer for the video'''
        vis = video_visualiser.Visualiser(self)
        pylab.show()
        return vis

    def thumbnails(self, rows=3, cols=3):
        '''Creates a montage image of the video with the number of rows by 
        columns specified.'''
        # TODO refactor merge with module function thumbnails which handles a 
        # list of arrays
        inds = np.linspace(0, self.frames - 1, rows*cols).astype(int)
        thumbs = self.V[inds, ...]

        montage = thumbs.reshape(rows, cols, self.rows, self.columns, self.bands)
        montage = montage.transpose((0, 2, 1, 3, 4))
        montage = montage.reshape(rows*self.rows, cols*self.columns, self.bands)
        return montage

    def save_images(self, dirpath, format = '.png', skip =1):
        ''' Saves all the frames of the video in the given directory path'''
        prefix = '%05d'
        for i in range(self.frames):
            if (i%skip != 0):
                continue
            filename = prefix % i
            filename = os.path.join(dirpath, filename) + format
	    print 'Index is '+ str(i)
            sp.misc.imsave(filename, self.V[i, ...])

    def colour_space_dt(self):
        '''Determines the change for each pixel as the euclidean distance in 
        colourspace.'''
        # TODO should this be done pixel by pixel to conserve memory
        dV = np.diff(np.float32(self.V), axis=0)
        dV_dt = pylab.vector_lengths(dV, axis=3)
        return asvideo(np.squeeze(dV_dt))

    def colour_space_edge(self):
        '''Determine spatial gradient in colour space'''
        # TODO this should be done frame by frame to conserve memory
        fV = np.float32(self.V)
        dV_dy = pylab.vector_lengths(np.diff(fV, axis=1), axis=3)
        dV_dx = pylab.vector_lengths(np.diff(fV, axis=2), axis=3)
        # make the shapes compatible by discarding right and bottom edges
        dV_dy = dV_dy[:,:,:-1]
        dV_dx = dV_dx[:,:-1,:]
        return asvideo(np.hypot(dV_dx, dV_dy))

    def apply_to_frames(self, func, args=None):
        '''Applies the given func to each image frame in the video, returning 
        an appropriately shaped and dtyped video'''
        # TODO this can be parallised perhaps through 
        # http://www.scipy.org/Cookbook/Multithreading?action=AttachFile&do=view&target=handythread.py
        # the GIL is released by numpy when processing an array in C

        im = self.V[0].copy() # copy so that the source video remains untouched
        if args is None:
            out_frame = func(im)
        else:
            out_frame = func(im, args)
        shape = (len(self.V), ) + out_frame.shape
        out = np.empty(shape, dtype=out_frame.dtype)
        # TODO should avoid recalculating the out_frame frame?
        # TODO also func should take an out argument to avoid reassigning memory 
        # for the output.
        for i, frame in enumerate(self.V):
            #func(frame, out=out_frame)
            #out[i] = out_frame
            im = frame.copy() # copy so that the source video remains untouched
            if args is None:
                out[i] = func(im)
            else:
                out[i] = func(im, args)
        return asvideo(out)

    def colour_map(self, cmap=pylab.cm.jet):
        '''Colour maps a video  that is not 3 channel uint8'''
        vmax = self.V.max()
        return self.apply_to_frames(_colour_map, vmax)
