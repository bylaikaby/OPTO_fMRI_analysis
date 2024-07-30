function filename = getnamefrompath(fullpath)
%GETNAMEFROMPATH - get filename from full pathname
%	filename = GETNAMEFROMPATH(fullpath)
%	NKL, 10.10.02

if (nargin < 1)
  error('usage: filename = getFileName(fullpath)')
end

token = findstr(fullpath, '\');
if (length(token))
   filename = fullpath(token(length(token))+1:length(fullpath));
else
  token = findstr(fullpath, '/');
  if (length(token))
    filename = fullpath(token(length(token))+1:length(fullpath));
  else
    filename = fullpath;
  end
end
