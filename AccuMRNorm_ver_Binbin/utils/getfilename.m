function fname = getfilename(SESSION,filespec)
%GETFILENAME - Get the filename from Ses and ExpNo or GrpName
%	fname = GETFILENAME(SESSION,filespec) returns the appropriate
%	file name whether the user enters an experiment number or a group
%	name.
%	NKL, 30.12.02

if nargin < 2,
	error('usage: fname = getfilename(SESSION,filespec);');
end;

Ses = goto(SESSION);

if isa(filespec,'char'),
	tmp = fieldnames(Ses.grp);
	if any(strcmp(filespec,tmp)),
		fname = strcat(filespec,'.mat');
		return;
	else
		fprintf('getfilename[ERROR}: Group does not exist\n');
		fprintf('getfilename[ERROR}: Available groups are: ');
		fprintf('%s ',tmp);
		keyboard;
	end;
end;

if isa(filespec,'double'),
	fname = catfilename(Ses,filespec,'mat');
	return;
end;

fprintf('getfilename[ERROR}: Second argument MUST be a Group Name or an ExpNo\n');
keyboard
