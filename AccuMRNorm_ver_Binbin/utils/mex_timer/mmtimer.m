% NOTICE :  If you have Matlab R13 or above, you may use 'timer' function.
%
% PURPOSE : Timer function for Matlab, using windows multimedia timer.
% USAGE :   mmtimer('command',timeridx,[delay],['type'],['callback'])
% ARGS :    command: 'SetTimer', 'KillTimer', 'KillAll',
%                    'GetTimerID', 'Resolution'
%           timeridx: 0 to 15
%           delay:    in msec
%           type:    'periodic' or 'oneshot'
%           callback: Matlab script
% NOTES :   Up to 16 timers are available.  The function returns 
%   immediately after starting the timer.  This allows you to run
%   your other Matlab script almost independently to the timer process. 
%   The function try to set 1ms resolution, however, this is 
%   system-dependent.  To see this value, use 'resolution' command.
% SEEALSO : timeGetDevCaps, timeBeginPeriod, timeEndPeriod, 
%           timeSetEvent, timeKillEvent (those are windows API)
% EXAMPLES :
%  To query timer resolution (in msec),
%    >> res = mmtimer('Resolution')
%  To start timer[0] periodically at 1000msec,
%    >> mmtimer('SetTimer',0,1000,'periodic','fprintf(''hello'');');
%  To get internal timer ID,
%    >> id = mmtimer('GetTimerID',0)
%  To kill timer[0]
%    >> mmtimer('KillTimer',0);
%
% compiled/tested under MSVC-6.0/Matlab-R12 on WindowsNT.
% VERSION : 1.01  26-Jul-02  Yusuke MURAYAMA, MPI
% 