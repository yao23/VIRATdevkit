This is a readme file for tracking for detection framework
Authors : Suren Kumar, Priyanshu Agarwal
Contact : surenkum@buffalo.edu
Last Update : Jun 25,2011

This code is made specifically for linux platform and tested on Ubuntu 11.04, 64 bit using MATLAB 7.11.0 (R2010b)

Please note that this code is a alpha version and might have a lot of bugs. Please report bugs to our contact email. 

How to use the code : 
1) Please make sure you can compile and run detector from Irobot.
2) Try to run the detection code on test.ppm. On our systems, we used to get Segmentation fault even though everything compiled correctly. For integrating detections within matlab and correcting this error, we made some changes to the files originally provided by Irobot. Copy files from folder detectcuda_code to the folder where original Irobot code is extracted. It replaces 'felz_example.cpp','felz_example_main.cpp','felz_example.h' and adds 'image.h','misc.h','pnmfile.h'. Now compile again and if everthing works correctly you should see an executable with name cudafelz_example. Copy this executable to trackdense folder so that matlab code can access it.
3) This executable alone can be run by ./cudafelz_example path_to_video detection_threshold path_to_detection_input_frames path_to_detection_overwritten_frames path_to_write_detection_csv
An example code snippet for doing the same is 
./cudafelz_example /big2t/istareproject/detection_cuda/trackdense/testvideo1.mov 1 /big2t/istareproject/detection_cuda/trackdense/det_input_frames /big2t/istareproject/detection_cuda/trackdense/detected_frames /big2t/istareproject/detection_cuda/trackdense/detections
Please note that code doesn't require any manual extraction of frames, it uses ffmpeg library to do that. Make sure ffmpeg is installed and can be run from inside matlab using system command.
4) Hence this executable for detection outputs detections in .csv format and writes detections on images to visualize detection results. Detection output has the format classid, xmin, ymin, xmax, ymax, where classid is the model id enumerated by referring to number of model in modelfile.txt. xmin, ymin are the upper left corner and  xman, ymax represent bottom right corner in standard image frame. If multiple detections are present on a single frame, all of them are written in a single line seperated by ',' operator. For different frames, detection are seperated by next line operator.
5) Tracking code can track a number of videos together in a single function call whose list is written a .txt file. You may find the command 'ls *.mov>videofile.txt' helpful to do that.
6) Tracking code can be invoked by 
final_main_tracker(vidlistfilename,vidlistdir,viddir,bboxdirectory,outdatadir,framedir,inpframedir,outframedir,detectionthresh);
Details of all these parameters are provided in the file init.m which also serves as an example file which could be tested.

% Describes format of Bounding Boxes for tracking
The naming format of file is the original videoname (without file (Ex:'.mov') extension) appended by '.csv' to denote a comma seperated file containing bounding box data for entities being tracked in the scene. We use ',' character to denote a column separator and a '/n' or newline operator as row separator.
The number of columns in comma seperated file is 1+4*number of entities where 1st column is used to specify the frame number and 4 columns are used to specify bounding box coordinates for each entity being tracked. Total number of rows is equal to total video frame. Example: For tracking two persons in a video, number of columns in output file will be 1+4*2 = 9
Bounding box format for each entity being tracked is [xmin,ymin,xmax,ymax] where xmin,ymin specify the minimum x and minimum y coordinates of bounding box in the image axes and xmax,ymax specify the maximum x and maximum y coordinates of bounding box in the image axes. (Image axes have origin at top left corner of image with positive x axis pointing towards right and positive y axis pointing downwards). So first two bounding box coordinates specify upper left corner of bounding box and last two coordinates specify bottom right corner of bounding box. 
If there are multiple entities in the scene, its relative column location is maintained in data format.Example : If two persons are being tracked, 1st column will always have frame number, next four columns will have data for 1st person and next four columns will have data for 2nd person corresponding to each frame. 
If any entity being tracked enters or leaves the scene, [0,0,0,0] is specified as its data for frame when entity is not present in the scene.   

To visualize the tracking results, use tracks_visualize.m file in utilites folder and change arguments for videofilename,viddirectory (directory where current video is located) and bboxdirectory (Directory where tracked bounding box file is written).

Acknowledgements: 
It uses dense optical code from [1] Antonin Chambolle and Thomas Pock, A first-order primal-dual
algorithm with applications to imaging, Technical Report, 2010
