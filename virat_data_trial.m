function [pos, rec_tmp] = virat_data_trial(cls)
  % % % positive process part
  % img_files = '~/Projects/object_detection/dataset/VIRAT_video_cut';
  img_files = '~/Desktop/VIRAT_video_cut2';
%   anno_files = dir('~/Projects/object_detection/tools/VIRATdevkit/VIRAT_Video/Annotations_tmp/*.txt');
  anno_files = dir('~/Projects/object_detection/tools/VIRATdevkit/VIRAT_Video/Annotations/*.txt');
  % anno_files = dir([VIRATopts.annopath '/*.txt']);
    
  num_anno_files = length(anno_files);
  numpos = 0;
  % read annotation file by file
  for i = 1 : num_anno_files
    rec_tmp = load(anno_files(i).name);
    [row col] = size(rec_tmp);
    % read line by line, row is the length of each anno_file
    for j = 1 : row
      switch cls
          case 'person'
              if( rec_tmp(j, 8) == 1 )
                  [numpos, pos] = pos_process(numpos, rec_tmp, i, j, img_files, anno_files);
              end
          case 'vehicle'
              if( rec_tmp(j, 8) == 2 || rec_tmp(j, 8) == 3)
                  [numpos, pos] = pos_process(numpos, rec_tmp);
              end
          case 'car'
              if( rec_tmp(j, 8) == 2 )
                  [numpos, pos] = pos_process(numpos, rec_tmp);
              end 
          case 'other vehicle'
              if( rec_tmp(j, 8) == 3 )
                  [numpos, pos] = pos_process(numpos, rec_tmp);
              end
          otherwise
              disp('other object type');
      end  
    end
  end

end
  
function [numpos, pos] = pos_process(numpos, rec_tmp, i, j, img_files, anno_files)
      numpos = numpos+1;
      % extract part before ‘.viratdata.objects.txt’, namely the video name,
      % e.g. filename == VIRAT_S_000001.viratdata.objects.txt
      folder_name = ['/' anno_files(i).name(1 : end-22) '/'];
      file_name = num2str(rec_tmp(j, 3), '%.6d'); 
      pos(numpos).im = [img_files folder_name file_name '.jpg'];
      pos(numpos).x1 = rec_tmp(j, 4);
      pos(numpos).y1 = rec_tmp(j, 5);
      pos(numpos).x2 = rec_tmp(j, 4) + rec_tmp(j, 6);
      pos(numpos).y2 = rec_tmp(j, 5) + rec_tmp(j, 7);
          
end