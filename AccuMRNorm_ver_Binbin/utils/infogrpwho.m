function infogrpwho(SESSION,GrpName,Func,LOG)
%INFOGRPWHO - List the variables of each MAT file that belongs to the group GrpName
% INFOGRPWHO (SESSION,GrpName,Func,LOG) displays information
% regarding the experiments of a given groups of "SESSION"
% NKL, 10.10.00
format compact;
close all;

if nargin < 4,
  LOG=0;
end;

if nargin < 3,
  Func = 'who';
end;

Ses = goto(SESSION);
grp = getgrpbyname(Ses,GrpName);

if LOG,
  InfoFile = strcat('WHO_',SESSION,'.log');
  if exist(InfoFile,'file'),
	delete(InfoFile);
  end;

  diary off;
  diary(InfoFile);
end;


for N=1:length(grp.exps),
  ExpNo = grp.exps(N);
  filename=catfilename(Ses,ExpNo,'mat');
  if ~exist(filename,'file'),
	fprintf('\ninfogrpwho: WARNING!!!! File %s does not exist\n\n',filename);
  else
	if strcmp(Func,'who'),
	  tmp = feval(Func,'-file',filename);
	  fprintf('%s(%3d): ', grp.name,ExpNo);
	  fprintf('%s ',tmp{:});
	  fprintf('\n');
	else
	  fprintf('%s(%3d)\n', grp.name,ExpNo);
	  feval(Func,'-file',filename);
	  fprintf('\n');
	end;
  end
end;

if LOG,
  diary off;
  edit(InfoFile);
end;
