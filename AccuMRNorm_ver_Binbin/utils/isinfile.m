function answ = isinfile(SesName,ExpNo,VarName)
%ISINFILE - Checks whether VarName is in file SesName/ExpNo
% ISINFILE (SESSION,ExpNo,VarName) checks whether a variable is in
% the mat file defined by catfilename(SesName,ExpNo);
% NKL, 10.10.00; 12.04.04

answ = 0;
filename = catfilename(SesName,ExpNo);
if ~exist(filename,'file'),
  fprintf('\nisinfile: WARNING!!!! File %s does not exist\n\n',filename);
else
  tmp = feval('who','-file',filename);
  if any(find(strcmp(tmp,VarName))),
    answ = 1;
  end;
end

