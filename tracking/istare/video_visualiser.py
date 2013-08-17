'''
Presents single frame of the video.  Click to select the pixel to be plotted 
over time.  Click outside the image to go to the next video.  Select which frame of the video to display by clicking in the pixel values versus time plot.

To exit you have to control-c in the terminal and then move the mouse into a plot window.

Author: Julian Ryde
'''

import sys

import pylab 
import numpy as np

import istare

#import threading
#
#class PlayVideo(threading.Thread):
#    def __init__ (self, V):
#        threading.Thread.__init__(self)
#        self.V = V
#    def run(self):
#        while True:
#            video.play_array(self.V)
#pv = PlayVideo(V)
#pv.start()

def init_fig(i):
    fig = pylab.figure(i)
    pylab.clf()
    return fig

def get_cross_sections(V, row, col):
    '''Retrieves the horizontal and vertical video volume cross-sections at the 
    given point'''
    hx = V[:, row, :, :]
    vx = V[:, :, col, :].transpose(1,0,2)
    return np.squeeze(hx), np.squeeze(vx)

class Visualiser:
    '''Initialising with a video array.'''


    def __init__(self, vid):
        self.row, self.col, self.frameno = 0, 0, 0
        self.vid = vid

        # set up the video frame image display
        #fig = init_fig(1)
        self.fig = pylab.figure()
        pad = 0.05
        pylab.subplots_adjust(left=pad, right=1, bottom=pad, top=1, wspace=pad, hspace=pad)
        srows, scols = 2, 2
        self.video_fig = pylab.subplot(srows, scols, 1)
        self.pixel_fig = pylab.subplot(srows, srows, 4)
        self.h_Xsection_fig = pylab.subplot(srows, scols, 3)
        self.v_Xsection_fig = pylab.subplot(srows, scols, 2)

        self.pixel_point = self.video_fig.plot( (self.col), (self.row), 'go')[0]
        im = np.squeeze(self.vid[0]) # needs to handle both 1 and 3 colour bands
        vmin = self.vid.V.min()
        vmax = self.vid.V.max()
        self.video_image = self.video_fig.imshow(im, interpolation='nearest', vmin=vmin, vmax=vmax, cmap=pylab.cm.jet)
        hx, vx = get_cross_sections(self.vid.V, self.row, self.col)
        self.h_Xsection_image = self.h_Xsection_fig.imshow(hx, interpolation='nearest')
        self.v_Xsection_image = self.v_Xsection_fig.imshow(vx, interpolation='nearest')

        # cm.gray, cm.jet
        self.rgb_lines = self.pixel_fig.plot(np.ones((len(vid), vid.bands)), '-x')
        #self.pixel_fig.axis(xmin=0, xmax=self.vid.V.shape[3], ymin=0, ymax=255)

        # setup event connections
        self.fig.canvas.mpl_connect('button_press_event', self.onclick_plot)

        # Initialise the vertical line representing the position in the video
        xdata = 2 * (self.frameno,)
        self.vline = self.pixel_fig.plot(xdata, [vmin, vmax])[0]
        #import pydb; pydb.set_trace()
        self._draw()

    def onclick_plot(self, event):
        #print 'button=%d, x=%d, y=%d, xdata=%f, ydata=%f'%( event.button, event.x, event.y, event.xdata, event.ydata)
        # determine which subplot it is in
        if event.inaxes == self.video_fig.axes:
            self.row = int(event.ydata)
            self.col = int(event.xdata)
        elif event.inaxes == self.pixel_fig.axes:
            self.frameno = int(event.xdata)
        #elif event.ydata is None: # user clicked outside image
            #self.__init__(istare.random_video())

        print self.frameno, self.row, self.col
        self._draw()

    def _draw(self):
        # Redraw video section
        im = np.squeeze(self.vid[self.frameno]) # needs to handle both 1 and 3 colour bands
        self.video_image.set_data(im)
        self.pixel_point.set_xdata((self.col))
        self.pixel_point.set_ydata((self.row))

        # Redraw plot section
        self.X = self.vid.V[:,self.row, self.col, :]
        for i in range(self.vid.bands):
            self.rgb_lines[i].set_ydata(self.X.T[i])
        #self.pixel_fig.axis(xmin=0, xmax=len(self.vid), ymin=0, ymax=255)

        # Redraw horizontal and vertical cross sections
        hx, vx = get_cross_sections(self.vid.V, self.row, self.col)
        self.h_Xsection_image.set_data(hx)
        self.v_Xsection_image.set_data(vx)

        # Move vertical line to selected frame number
        xdata = 2 * (self.frameno,)
        self.vline.set_xdata(xdata)

        pylab.draw()

if __name__ == '__main__':
    if len(sys.argv) == 1:
        vid = istare.random_video(factor=4)
    else:
        vid = istare.get_video(sys.argv[1], factor=4)
    vis = Visualiser(vid)

    print __doc__
    pylab.show()
