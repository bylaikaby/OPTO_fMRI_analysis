function info1who(SESSION,Func,LOG)
%INFO1WHO - List the variables in the 1st file of each group
% INFO1WHO (SesName) the function is used to find out how far are
% we with the processing of data. It uses the who('-file') option
% to check the current variables in the first experiment of each
% group of a given session.
% NKL, 10.10.00
% NKL, 07.01.06
  
format compact;
close all;

if nargin < 4,
  LOG=0;
end;

if nargin < 3,
  Func = 'who';
end;

Ses = goto(SESSION);
grps = getgroups(Ses);
if LOG,
  InfoFile = strcat('WHO_',SESSION,'.log');
  if exist(InfoFile,'file'),
	delete(InfoFile);
  end;

  diary off;
  diary(InfoFile);
end;


for N=1:length(grps),
  ExpNo = grps{N}.exps(1);
  filename=catfilename(Ses,ExpNo,'mat');
  anap = getanap(Ses,ExpNo);
  stm = grps{N}.stminfo;
  if ~(strcmp(stm,'blank') | strcmp(stm,'spont') | strcmp(stm,'none')),
    stm = 'STIM';
  end;
  rg = char(grps{N}.refgrp.grpexp);
  
  tri = anap.gettrial.status;
  if tri,
    tri = 'Trial';
  else
    tri = 'Obspd';
  end;
  if ~exist(filename,'file'),
	fprintf('\ninfo1who: WARNING!!!! File %s does not exist\n\n',filename);
  else
	if strcmp(Func,'who'),
	  tmp = feval(Func,'-file',filename);
	  fprintf('%16s(%3d): RG: %- 11s %s %s ', grps{N}.name,ExpNo, rg, stm,tri);
	  fprintf('%s ',tmp{:});
	  fprintf('\n');
	else
	  fprintf('%16s(%3d): RG: %- 11s %s %s ', grps{N}.name,ExpNo, rg, stm,tri);
	  feval(Func,'-file',filename);
	  fprintf('\n');
	end;
  end
end;

if LOG,
  diary off;
  edit(InfoFile);
end;
