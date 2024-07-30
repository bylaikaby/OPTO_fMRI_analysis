function lspar(SESSION,ExpNo,Field)
%LSPAR - ls par from PARsession.mat for ExpNo and Field (e.g. img)
%	LSPAR(SESSION,ExpNo,Field) - reads ParSESSION.mat and displays
%	the parameters of the experiment ExpNo for a determined field.
%	NKL, 03.12.02

ep = sesparload(SESSION);
ep = ep{ExpNo};

if nargin < 3,
	ep
	return;
end;

eval(sprintf('ep.%s',Field));

