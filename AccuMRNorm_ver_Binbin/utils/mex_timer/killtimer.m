function killtimer(timerid)
% PURPOSE : To kill timer
% USAGE :   killtimer(timerid)
% ARGS :    timerid = 0-15, if -1, kill all timers.
% VERSION : 1.00  05-Aug-02  Yusuke MURAYAMA, MPI

if nargin == 0,
  help killtimer;
  return;
end

if timerid < 0,
  mmtimer('KillAll');
else
  mmtimer('KillTimer',timerid);
end
