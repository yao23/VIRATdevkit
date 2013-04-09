function [pos, neg] = virat_data_trial(cls)
  % [pos, neg] = virat_data(cls)
  % Get training data from the VIRAT dataset.

  globals; 
  virat_init;

  % % % positive process part
  % img_files = '~/Projects/object_detection/dataset/VIRAT_video_cut';
  img_files = '~/Desktop/VIRAT_video_cut2';
%   anno_files = dir('~/Projects/object_detection/tools/VIRATdevkit/VIRAT_Video/Annotations_tmp1/*.txt');
%   anno_files = dir('~/Projects/object_detection/tools/VIRATdevkit/VIRAT_Video/Annotations_tmp/*.txt');
  anno_files = dir('~/Projects/object_detection/tools/VIRATdevkit/VIRAT_Video/Annotations/*.txt');
  % anno_files = dir([VIRATopts.annopath '/*.txt']);
    
  num_anno_files = length(anno_files);
  numpos = 0;
  numneg = 0;
  pos = [];
  neg = [];
  % read annotation file by file
  for i = 1 : num_anno_files
    rec_tmp = load(anno_files(i).name);
    
    [pos_tmp, neg_tmp] = pos_neg_init_process(rec_tmp, cls);
    
    [row col] = size(rec_tmp);
    % read line by line, row is the length of each anno_file
    for j = 1 : row
      switch cls
          case 'person'
              pos = rec_tmp( rec_tmp(:,8)==1, 3:7 );
              neg_tmp = rec_tmp( rec_tmp(:,8)~=1, 3:7 );
              frame_pos = pos(:, 1);
              frame_neg_tmp1 = neg_tmp(:, 1);
              frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
              frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
              neg = neg_tmp(frame_neg, :);
              
          case 'vehicle'
              pos = rec_tmp( ismember(rec_tmp(j, 8), [2,3]), 3:7 );
              neg_tmp = rec_tmp( rec_tmp(:,8)~=1, 3:7 );
              frame_pos = pos(:, 1);
              frame_neg_tmp1 = neg_tmp(:, 1);
              frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
              frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
              neg = neg_tmp(frame_neg, :);
              
          case 'car'
              pos = rec_tmp( rec_tmp(:,8)==2, 3:7 );
              neg_tmp = rec_tmp( rec_tmp(:,8)~=2, 3:7 );
              frame_pos = pos(:, 1);
              frame_neg_tmp1 = neg_tmp(:, 1);
              frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
              frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
              neg = neg_tmp(frame_neg, :);
              
          case 'other vehicle'
              pos = rec_tmp( rec_tmp(:,8)==3, 3:7 );
              neg_tmp = rec_tmp( rec_tmp(:,8)~=3, 3:7 );
              frame_pos = pos(:, 1);
              frame_neg_tmp1 = neg_tmp(:, 1);
              frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
              frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
              neg = neg_tmp(frame_neg, :);
              
          otherwise
              disp('other object type');
      end  
    end
  end
  save([cachedir cls '_train'], 'pos', 'neg');
end

function [pos, neg] = pos_neg_init_process(rec_tmp, cls)
  switch cls
    case 'person'
      pos = rec_tmp( rec_tmp(:,8)==1, 3:7 );
      neg_tmp = rec_tmp( rec_tmp(:,8)~=1, 3:7 );
      frame_pos = pos(:, 1);
      frame_neg_tmp1 = neg_tmp(:, 1);
      frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
      frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
      neg = neg_tmp(frame_neg, :);
              
    case 'vehicle'
      pos = rec_tmp( ismember(rec_tmp(:, 8), [2,3]), 3:7 );
      neg_tmp = rec_tmp( ismember(rec_tmp(:, 8), [0,1,4,5]), 3:7 );
      frame_pos = pos(:, 1);   
      frame_neg_tmp1 = neg_tmp(:, 1);
      frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
      frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
      neg = neg_tmp(frame_neg, :);
              
    case 'car'
      pos = rec_tmp( rec_tmp(:,8)==2, 3:7 );
      neg_tmp = rec_tmp( rec_tmp(:,8)~=2, 3:7 );
      frame_pos = pos(:, 1);
      frame_neg_tmp1 = neg_tmp(:, 1);
      frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
      frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
      neg = neg_tmp(frame_neg, :);
              
    case 'other vehicle'
      pos = rec_tmp( rec_tmp(:,8)==3, 3:7 );
      neg_tmp = rec_tmp( rec_tmp(:,8)~=3, 3:7 );
      frame_pos = pos(:, 1);
      frame_neg_tmp1 = neg_tmp(:, 1);
      frame_neg_tmp2 = setxor(frame_neg_tmp1, intersect(frame_neg_tmp1, frame_pos));
      frame_neg = ismember(frame_neg_tmp1, frame_neg_tmp2);
      neg = neg_tmp(frame_neg, :);
                       
    otherwise
      disp('other object type');
  end  

end 

function [numpos, pos] = pos_process(pos, numpos, rec_tmp, i, j, img_files, anno_files)
      numpos = numpos + 1;
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

function [numneg, neg] = neg_process(neg, numneg, rec_tmp, i, j, img_files, anno_files) 
  numneg = numneg + 1;
  folder_name = ['/' anno_files(i).name(1 : end-22) '/'];
  file_name = num2str(rec_tmp(j, 3), '%.6d'); 
  neg(numneg).im = [img_files folder_name file_name '.jpg'];
end
  