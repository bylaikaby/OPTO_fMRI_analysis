function carr = num2str2cell(Val)
%NUM2STR2CELL - It converts numbers to cell array of strings
% CARR = NUM2STR2CELL (Val) ridiculuously enough Matlab does not have this
% function!

for N=1:length(Val),
  carr{N} = num2str(Val(N));
end;

  