function varargout = exptime(SESSION,ExpNo)
%EXPTIME - returns date/time string of the experiment.
%  TSTR = EXPTIME(SESSION,EXPNO) returns date/time string of the experiment.
%  'TSTR' will be like 'Fri Feb 24 13:17:48 2006'.
%  EXPTIME(SESSION,EXPNO) simply prints out date/time string of 'EXPNO'.
%
%  EXAMPLE :
%    >> exptime('ratai1',1)                             % prints the date-string
%    >> t1 = exptime('ratai1',1)                        % get the date-string
%    >> t2 = exptime('ratai1',2)
%    >> n1 = datenum(t1(5:end),'mmm dd HH:MM:SS yyyy'); % convert to date-number
%    >> n2 = datenum(t2(5:end),'mmm dd HH:MM:SS yyyy');
%    >> etime(datevec(n2),datevec(n1))                  % difference in sec
%
%  NOTE :
%    datenum(exptime('ratai1',1),'ddd mmm dd HH:MM:SS yyyy')) causes an error in Matlab7.1.
%    So above example use t(5:end) removing day-string.
%
%  VERSION :
%    0.90 06.07.06 YM  pre-release
%
%  See also EXPGETPAR DATENUM ETIME

if nargin == 0,  eval(sprintf('help %s',mfilename)); return;  end


Ses = goto(SESSION);

if nargin == 1,
  EXPS = sort(validexps(Ses));
else
  if isnumeric(ExpNo),
    EXPS = ExpNo;
  else
    % 'ExpNo' as a group
    grp = getgrp(Ses,ExpNo);
    EXPS = grp.exps;
  end
end


EXPTIME = {};
for iExp = 1:length(EXPS),
  par = expgetpar(Ses,EXPS(iExp));
  EXPTIME{iExp} = par.evt.date;
end
if length(EXPTIME) == 1,  EXPTIME = EXPTIME{1};  end


if nargout > 0,
  varargout{1} = EXPTIME;
  if nargout >= 2,
    varargout{2} = EXPS;
  end
else
  if length(EXPS) == 1,
    fprintf('%s\n',EXPTIME);
  else
    t1 = datevec(datenum(EXPTIME{1}(5:end),'mmm dd HH:MM:SS yyyy'));
    for iExp = 1:length(EXPS),
      tx = datevec(datenum(EXPTIME{iExp}(5:end),'mmm dd HH:MM:SS yyyy'));
      fprintf('%s ExpNo=%3d:  %s  (elapsed %ds)\n',Ses.name,EXPS(iExp),EXPTIME{iExp},...
              round(etime(tx,t1)));
    end
  end
end

return;
