function lsgrp(SESSION,GrpName)
%LSGRP - ls group fields
%	LSGRP(SESSION)
%	NKL, 29.11.02

Ses = goto(SESSION);

if nargin < 2,
  grps = getgroups(Ses);
  fprintf('Session %s has %d groups\n', Ses.name, length(grps));
  for N=1:length(grps),
	grps{N}
  end;
else
  eval(sprintf('grp = Ses.grp.%s;',GrpName));
  grp
end;




