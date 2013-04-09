function [pos, neg] = virat_data_beta(cls)
  % [pos, neg] = virat_data(cls)
  % Get training data from the VIRAT dataset.

  globals; 
  virat_init;

  % % % positive process part
  img_files = '~/Desktop/VIRAT_video_cut2';
  anno_files = dir('~/Projects/object_detection/tools/VIRATdevkit/VIRAT_Video/Annotations_tmp2/*.txt');

    
  num_anno_files = length(anno_files);
  numpos = 0;
  numneg = 0;  
  pos = [];
  neg = [];

  % read annotation file by file
  for i = 1 : num_anno_files
  
    rec_tmp = load(anno_files(i).name);
    
    [pos_tmp, neg_tmp] = pos_neg_init_process(rec_tmp, cls);
     
    [pos, numpos] = pos_process(pos, pos_tmp, numpos, i, img_files, anno_files);
    [neg, numneg] = neg_process(neg, neg_tmp, numneg, i, img_files, anno_files);
    
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

function [pos, numpos] = pos_process(pos, pos_tmp, numpos, i, img_files, anno_files)
  [row col] = size(pos_tmp);  
  for j = 1 : row
      numpos = numpos + 1;
      % extract part before ‘.viratdata.objects.txt’, namely the video name,
      % e.g. filename == VIRAT_S_000001.viratdata.objects.txt
      folder_name = ['/' anno_files(i).name(1 : end-22) '/'];
      file_name = num2str(pos_tmp(j, 1), '%.6d'); 
      pos(numpos).im = [img_files folder_name file_name '.jpg'];
      pos(numpos).x1 = pos_tmp(j, 2);
      pos(numpos).y1 = pos_tmp(j, 3);
      pos(numpos).x2 = pos_tmp(j, 2) + pos_tmp(j, 4);
      pos(numpos).y2 = pos_tmp(j, 3) + pos_tmp(j, 5);
  end
end

function [neg, numneg] = neg_process(neg, neg_tmp, numneg, i, img_files, anno_files)
  [row col] = size(neg_tmp);  
  for j = 1 : row
      numneg = numneg + 1;
      folder_name = ['/' anno_files(i).name(1 : end-22) '/'];
      file_name = num2str(neg_tmp(j, 1), '%.6d'); 
      neg(numneg).im = [img_files folder_name file_name '.jpg'];
  end
end
  