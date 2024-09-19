function [scrW, scrH] = getScreenSize(Units)
%GETSCREENSIZE - get screen size of the monitor
% PURSPOE : To get screen size of the display.
% USAGE : [scrW, scrH] = getScreenSize(Units)
%         "Units" : 'char' or 'pixels'.
% VERSION : 0.9 19.12.03  YM
% See also MGUI, DGZVIEWER, ADFVIEWER, IMGVIEWER

if nargin == 0, Units = 'pixels';  end
  
oldUnits = get(0,'Units');
set(0,'Units',Units);
sz = get(0,'ScreenSize');
set(0,'Units',oldUnits);

scrW = sz(3);  scrH = sz(4);
