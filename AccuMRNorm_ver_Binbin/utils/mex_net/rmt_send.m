function result = rmt_send(server,cmdstr,tout)
% PURPOSE : To communicate with the stim program.
% USAGE :   result = rmt_send(server,cmdstr,[tout]);
%           'tout': socket timeout in msec.
% SEEALSO : netstimctrl.m, netstimctrl.c essnetapi.c
% REQUIRE : netstimctrl.dll
% VERSION : 1.00 11.05.03  YM

if nargin < 2,  help rmt_send; return;   end
if nargin > 2,
  netstimctrl('timeout',tout);
else
  netstimctrl('timeout',-1);
end
result = netstimctrl('send',server,cmdstr);
