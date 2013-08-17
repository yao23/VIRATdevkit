'''
Extracts human silhouette using templates.
Uses Felzenswalb's code to get bounding box and Boundary Structure Segmentation to get silhouette of image inside the bounding box.
Both these codes need to be present in folder /istare_repo/thirdparty/
Returns binary video object.
Example :
import istare
import istare.silhouette_detection as sd
vid = istare.random_video()
sv = sd.get_silhouette(vid)

Srijan Kumar
'''

import istare
import istare.video as video
import numpy as np
import subprocess as subp
import os
import Image

def get_silhouette(vid):
	'''
	Do the silhouette detection on given video.
	Returns binary video of silhouettes.
	'''
	
	vid_id = istare.get_ID(vid.source)
	imgpath = '/tmp/vidimg/'
	subp.call('mkdir ' + imgpath, shell = True)
	vid.save_images(imgpath,'.bmp')
	
	subp.call('mkdir /tmp/vidimgjpg/',shell=True)
	vid2 = istare.get_video(vid_id,2);
	vid2.save_images('/tmp/vidimgjpg/','.jpg')

	fullpath = os.path.abspath(vid.source)
	pypath = os.environ['PYTHONPATH']
	
	#silhouette extraction requires two further details to continue processing : imgpath (the path to the stored images) and pypath (the PYTHONPATH)
	#passing them onto the matlab code doesnot work due to difference in string processing in py and matlab
	#So, store data into some file and use from there!
	fid = open('/tmp/path_det','w')
	fid.write(imgpath + '\n')
	fid.write(pypath)
	fid.close()
	
	print 'Detecting humans...'
	subp.call('matlab -nodesktop -nosplash -r "cd '+pypath+'/thirdparty/voc-release4/;detecting_box_new();exit;"',shell=True)
	
	for i in range(np.size(os.listdir('/tmp/sil_det/'))):
		im = Image.open('/tmp/sil_det/' + '%05d'%i + '.jpg')
		im = im.convert('RGB')
		im.save('/tmp/sil_det/' + '%05d'%i + '.jpg')

	sil_vid = video.load_images('/tmp/sil_det/')
	sil_vid.V = sil_vid.V > 150
	sil_vid.V = sil_vid.V[...,0] & sil_vid.V[...,1] & sil_vid.V[...,2]
	sil_vid.V.shape = (sil_vid.V.shape[0],sil_vid.V.shape[1],sil_vid.V.shape[2],1)

	subp.call('rm -r /tmp/vidimg/',shell=True)
	subp.call('rm -r /tmp/sil_det/',shell=True)
	subp.call('rm /tmp/path_det',shell=True)
	subp.call('rm /tmp/bbox',shell=True)
	subp.call('rm -r /tmp/temp/',shell=True)
	subp.call('rm -r /tmp/vidimgjpg/',shell=True)

	return sil_vid
