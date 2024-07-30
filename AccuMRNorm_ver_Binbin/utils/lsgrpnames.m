function lsgrpnames(SESSION)
%LSGRPNAMES - ls group fields
%	LSGRPNAMES(SESSION)
%	NKL, 29.11.02

Ses = goto(SESSION);
grps = getgroups(Ses);
fprintf('Session %s has %d groups\n', Ses.name, length(grps));
for N=1:length(grps),
	fprintf('%s\n', grps{N}.name);
end;



