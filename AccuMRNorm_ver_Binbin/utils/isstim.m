function type = isstim(SESSION,GrpName)
%ISSTIM - Returns whether the group data were collected with a sensory stimulus
% ISSTIM(grp) returns type for a group
% ISSTIM(SESSION,GrpName) returns type for group of session
% ISSTIM(SESSION,ExpNo) returns type for exp. of session
% NKL, 1.06.03

if nargin == 0,  help isstim; return;  end

Ses = goto(SESSION);

if nargin == 1,
  grps = getgroups(Ses);
  for N=1:length(grps),
    grp = getgrpbyname(Ses,grps{N}.name);
    par = expgetpar(Ses,grp.name);
    type = ~all(strcmpi(par.stm.stmtypes,'blank'));
    if type, txt = 'stim'; else txt = 'none'; end;
    fprintf('%s:%s = %s\tStimInfo: %s; Condition: %s\n', ...
            Ses.name, grps{N}.name, txt, grp.stminfo, grp.condition{1});
  end;
  return;
end;
  
if nargin > 1,
  grp = getgrp(Ses,GrpName);
else
  if isa(SESSION,'char'),
	names = fieldnames(Ses.grp);
	grp = getgrpbyname(Ses,names{1});
  else
	if isfield(SESSION,'grp'),
	  names = fieldnames(SESSION.grp);
	  grp = getgrpbyname(SESSION,names{1});
	else
	  grp = SESSION;
	end;
  end;
end;

par = expgetpar(Ses,grp.name);
type = ~all(strcmpi(par.stm.stmtypes,'blank'));

if 0,
if any(strcmp('stim',grp.stminfo)),
  type=1;
else
  type=0;
end;
end;


