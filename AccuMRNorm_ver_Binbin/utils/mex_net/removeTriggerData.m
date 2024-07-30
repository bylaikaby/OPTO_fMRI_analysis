function [wave,nchans] = removeTriggerData(rwave,threshold)
% PURPOSE : To remove a trigger channel from data
% ARGS :    rwave(chan,t)
% USAGE :   [wave,nchans] = removeTriggerData(rwave,[threshold])
% VERSION : 1.00  11-Aug-2002  YM
%           1.01  14-Aug-2002  YM, bug fix for obs detection

wave = [];  nchans = 0;

% is there a trigger channel
if size(rwave,1) == 1, 
  wave = rwave;  nchans = 1;  return;
end

% set threshold
if nargin < 2,
  threshold = 16000;  % about 2.5V = 65536/10*2.5
% threshold = 12000;  % about 1.8V = 65536010*1.8
end

% number of signals
nchans = size(rwave,1)-1;
% get trigger channel
trig = rwave(nchans+1,:);
% get high periods
tsel = find(trig >= threshold);
%length(tsel),size(rwave)

% always low
if length(tsel) == 0,  return;  end
% always high
if length(tsel) == size(rwave,2),
  wave = rwave(1:nchans,:);  return;
end

% detect latest low-high
ts   = tsel(max(find(diff([0,tsel]) > 1)));
te   = max(tsel);
wave = rwave(1:nchans,ts:te);
