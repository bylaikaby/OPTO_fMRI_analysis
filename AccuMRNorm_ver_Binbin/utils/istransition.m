function type = istransition(SESSION,GrpName)
%ISTRANSITION - Returns whether the group data were during "transition" (anesth-recovery)
% ISTRANSITION(grp) returns type for a group
% ISTRANSITION(SESSION,GrpName) returns type for group of session
% ISTRANSITION(SESSION,ExpNo) returns type for exp. of session
% NKL, 1.06.03

if nargin == 0,  help istransition; return;  end  

if nargin > 1,
  Ses = goto(SESSION);
  grp = getgrp(Ses,GrpName);
else
  if isa(SESSION,'char'),
	Ses = goto(SESSION);
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

if any(strcmp('transition',grp.condition)),
  type=1;
else
  type=0;
end;

