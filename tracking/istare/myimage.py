import cv
import os
import numpy as np
import Image

def scale_image(I):
    '''Scale max value to 255 and cast to uint8 for imshowing alongside other 
    arrays'''
    # Massage various input shapes into the correct shape
    if I.ndim == 2:
        I = I[..., np.newaxis]
    if I.shape[2] == 1:
        I = np.tile(I, (1,1,3))
    return np.uint8(I * 255.0/I.max())

def normalise_image(im, args=None):
    '''Divides each colour by the total and scales to 255.  Places the mean in the last channel.
      R   ,   B   , R+G+B
    R+G+B   R+G+B     3
    '''
    sumI = im.sum(axis=2)
    N = np.empty(im.shape, dtype=np.float32)
    N[...,0] = 255 * np.true_divide(im[...,0], sumI)
    N[...,1] = 255 * np.true_divide(im[...,1], sumI)
    N[...,2] = np.true_divide(sumI, 3)

    #N = np.float32(im)/sumI[:,:,np.newaxis]
    # division by 0 results in nan
    N[np.isnan(N)] = 0
    return np.uint8(np.round(N))

def image_array(frame):
    # TODO do the conversion properly with code on this web page
    # http://opencv.willowgarage.com/documentation/python/cookbook.html
    frame_arr = np.asarray(cv.GetMat(frame))

    if frame_arr.ndim == 3:
        frame_arr = frame_arr[:, :, ::-1] # reverse RGB
    else:
        frame_arr.shape = frame_arr.shape[0], frame_arr.shape[1], 1
    return frame_arr

def array_image(imgArray):
    '''convert numpy array to an IplImage'''
    shp = imgArray.shape
    if shp[2] == 1: #Image colorspace is grayscale
        tempImgArray = np.reshape(imgArray,(shp[0],shp[1]))
    else:
        tempImgArray = imgArray
    pilImg = Image.fromarray(tempImgArray)
    cvImg = cv.CreateImage(pilImg.size,cv.IPL_DEPTH_8U,shp[2])
    dst = cvImg
    cv.SetData(cvImg,pilImg.tostring())
    cv.CvtColor(cvImg,dst,cv.CV_BGR2RGB)
    return dst

def array_image_test(a):
    dtype2depth = {
        'bool': cv.IPL_DEPTH_8U,
        'uint8':   cv.IPL_DEPTH_8U,
        'int8':    cv.IPL_DEPTH_8S,
        'uint16':  cv.IPL_DEPTH_16U,
        'int16':   cv.IPL_DEPTH_16S,
        'int32':   cv.IPL_DEPTH_32S,
        'float32': cv.IPL_DEPTH_32F,
        'float64': cv.IPL_DEPTH_64F,
    }
    try:
        nChannels = a.shape[2]
    except:
        nChannels = 1
    cv_im = cv.CreateImageHeader((a.shape[1],a.shape[0]),
          dtype2depth[str(a.dtype)],
          nChannels)
    cv.SetData(cv_im, a.tostring(),
             a.dtype.itemsize*nChannels*a.shape[1])
    return cv_im

def framediff(A, B):
    '''Mimic the opencv absdiff but for arrays'''
    C = A.astype(np.int16) - B.astype(np.int16) 
    diff = np.abs(C).astype(np.uint8)
    return diff

class MyImage:
    def __init__(self, fname):
        if not os.path.exists(fname):
            raise IOError(fname + ' not found')
        self._image = cv.LoadImage(fname)
	self._asarray = image_array(self._image)	
        self.fname = fname
        self.width = self._image.width
        self.height = self._image.height
        self._resized_im = None
	self._color_space = None
	self._colorspaceoptions = [x for x in dir(cv) if x.startswith('CV_BGR2')]

    # def display()
    # def asarray()
    def convert_colorspace(self, cspace):
        # TODO handle case with incorrect color space option
	self._color_space = cspace
        if self._color_space == 'GRAY':
            temp = cv.CreateImage((self.width,self.height),cv.IPL_DEPTH_8U,1)
            cv.CvtColor(self._image,temp,cv.CV_BGR2GRAY)
        else:
            cs = [cs for cs in self._colorspaceoptions if cs.endswith(self._color_space)]
            temp = self._image
	    if(cs != []):	
                cv.CvtColor(self._image, temp, getattr(cv, cs[0]))

        self._image = temp
	self._asarray = image_array(self._image)	

    def asarray(self):
        return self._asarray	

    def resize(self,newwidth,newheight):
        if self._color_space == 'GRAY':
            temp = cv.CreateImage((newwidth,newheight),cv.IPL_DEPTH_8U,1)
	else:
            temp = cv.CreateImage((newwidth,newheight),cv.IPL_DEPTH_8U,3)
        cv.Resize(self._image, temp, cv.CV_INTER_AREA)
        self._image = temp
	self.width = newwidth
	self.height = newheight
	self._asarray = image_array(self._image)	
