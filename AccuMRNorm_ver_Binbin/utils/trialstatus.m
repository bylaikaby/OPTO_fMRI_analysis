function RET = trialstatus(Ses,GrpExp,SigName)
%TRIALSTATUS - returns anap.gettrial.status
%  STATUS = trialstatus(SESSION,GRPEXP)
%  STATUS = trialstatus(SESSION,GRPEXP,SigName)
%
%  VERSION :
%    0.90 19.02.07 YM  pre-release
%    0.91 19.04.13 YM  supports 'SigName'
%
%  See also getanap

if nargin == 0,  eval(sprintf('help %s;',mfilename)); return;  end

if nargin < 3,  SigName = '';  end


RET = 0;
% GET BASIC INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
anap = getanap(Ses,GrpExp);

if any(SigName),
  % anap.(signame).gettrial
  if isfield(anap,SigName) && isfield(anap.(SigName),'gettrial'),
    if isfield(anap,'gettrial')
      anap.gettrial = sctmerge(anap.gettrial,anap.(SigName).gettrial);
    else
      anap.gettrial = anap.(SigName).gettrial;
    end
  end
  % anap.gettrial.(signame)
  if isfield(anap,'gettrial') && isfield(anap.gettrial,SigName),
    anap.gettrial = sctmerge(anap.gettrial,anap.gettrial.(SigName));
  end
end


if isfield(anap,'gettrial') && isfield(anap.gettrial,'status')
  RET = anap.gettrial.status;
  if isempty(RET),  RET = 0;  end
end



return
