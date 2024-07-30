function filepath = getdirfrompath(fullpath)
%GETDIRFROMPATH - Extracts directory from fullpath (e.g. f:/temp/)
%	filepath = getdirfrompath(fullpath)
%	YM APR-2000

if (nargin < 1)
  error('usage: filepath = getdirfrompath(fullpath)')
end

token = findstr(fullpath, '\');
if (length(token))
   filepath = fullpath(1:token(length(token))-1);
else
  token = findstr(fullpath, '/');
  if (length(token))
    filepath = fullpath(1:token(length(token))-1);
  else
    filepath = '';
  end
end
