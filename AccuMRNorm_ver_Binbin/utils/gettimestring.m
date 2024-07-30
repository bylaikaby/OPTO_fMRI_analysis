function tstr = gettimestring(t)
%GETTIMESTRING - get time as a string
% TSTR = GETTIMESTRING(T)
% PURPOSE : To get a string representing time.
% USAGE : tstr = gettimestring([t])
% ARG :   't' is a return value of 'clock'.
% VERSION : 1.00  14-May-2000 YM
%
% See also CLOCK

if nargin < 1, t = clock; end
t = fix(t);
if length(t) == 1
  h = fix(t/3600);
  m = mod(fix(t/60),60);
  s = mod(t,60);
else
  h = t(4);
  m = t(5);
  s = t(6);
end
if nargout == 0
  fprintf('%02d:%02d:%02d\n',h,m,s);
else
  tstr = sprintf('%02d:%02d:%02d',h,m,s);
end