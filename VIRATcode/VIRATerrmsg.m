function VIRATerrmsg(VIRATerr,SYSerr)
  fprintf('VIRAT Error Message: %s\n', VIRATerr);
  fprintf('System Error Message: %s\n',SYSerr);
  k=input('Enter K for keyboard, any other key to continue or ^C to quit ...','s');
  if (~isempty(k)), if (lower(k)=='k'), keyboard; end; end;
  fprintf('\n');
return