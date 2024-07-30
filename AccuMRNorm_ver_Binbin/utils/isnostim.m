function type = isnostim(SESSION,GrpName)
%ISNOSTIM - Returns whether recording/imaging group data were collected w/out stimulation
% ISNOSTIM(grp) returns type for a group
% ISNOSTIM(SESSION,GrpName) returns type for group of session
% ISNOSTIM(SESSION,ExpNo) returns type for exp. of session
% NKL, 1.06.03

if nargin == 0,  help isnostim; return;  end

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

if any(strcmp('nostim',grp.stminfo)) | any(strcmp('none',grp.stminfo)),
  type=1;
else
  type=0;
end;

