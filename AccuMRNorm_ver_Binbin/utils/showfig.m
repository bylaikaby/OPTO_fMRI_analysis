function showfig(varargin)
%SHOWFIG - brings the current figure inside the monitor.
%  SHOWFIG() brings the current figure inside the monitor.
%  Deu to MatLab's bug, sometimes, a figure is created outside the monitor...
%
%  VERSION :
%    0.90 13.03.07 YM  pre-release
%
%  See also GET SET GCF

% >> figure;
% >> pos = get(gcf,'pos')
% pos =
%        32772       33478         560         420
% >> set(gcf,'pos',[100 100 560 420]);

tmpunits = get(gcf,'units');
set(gcf,'units','pixels');
pos = get(gcf,'pos');
if any(abs(pos(1:2)) > 10000),
  set(gcf,'pos',[100 100 pos(3) pos(4)]);
end
set(gcf,'units',tmpunits);

return
