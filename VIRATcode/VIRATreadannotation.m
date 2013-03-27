function record = VIRATreadannotation(filename)
  [fd,syserrmsg]=fopen(filename,'rt');
  if (fd==-1),
    VIRATmsg=sprintf('Could not open %s for reading',filename);
    VIRATerrmsg(VIRATmsg,syserrmsg); 
  end;
%%% example filename = '~/Projects/object_detection/tools/mywork/...
%%% VIRAT_Video/Annotations/VIRAT_S_000001.viratdata.objects.txt';
record=VIRATemptyrecord;
rec_tmp = load(filename);
[row col] = size(rec_tmp);
for i = 1:row
  record.objects(i).label=char(rec_tmp(i,8));
  xmin = rec_tmp(i, 4);
  xmax = rec_tmp(i, 4) + rec_tmp(i, 6);
  ymin = rec_tmp(i, 5);
  ymax = rec_tmp(i, 5) + rec_tmp(i, 7);
  record.objects(i).bbox=[min(xmin,xmax),min(ymin,ymax),max(xmin,xmax),max(ymin,ymax)];
end 

end