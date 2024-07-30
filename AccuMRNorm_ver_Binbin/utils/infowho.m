function infowho(SESSION,VarName,Func,LOG)
%INFOWHO - Searches for variable "VarName" in all files of a session
% INFOWHO(SesName,VarName,Func,LOG) the function is used to find out how far are we with the
% processing of data. It uses the who('-file') option to check the current variables in each
% experiment of a given session.
% NKL, 10.10.00

format compact;
close all

if nargin < 4,
  LOG = 0;
end;

if nargin < 3,
  Func = 'who';
end;

if nargin < 2,
  VarName = '';
end;

Ses = goto(SESSION);
EXPS = validexps(Ses);

if LOG,
  InfoFile = strcat('WHO_',SESSION,'.log');
  if exist(InfoFile,'file'),
	delete(InfoFile);
  end;
  diary off;
  diary(InfoFile);
end;

g = 'none';
for N=1:length(EXPS),
  ExpNo = EXPS(N);
  grp=getgrp(Ses,ExpNo);
  if ~strcmp(g,grp.name),
	fprintf('\n');
	g=grp.name;
	fprintf('EXPINFO: ');
	fprintf('%s ',grp.expinfo{:});
	fprintf('\nSTMINFO: %s\n',grp.stminfo);
  end;
  
  filename=catfilename(Ses,ExpNo,'mat');
  if ~exist(filename,'file'),
	fprintf('\ninfowho: WARNING!!!! File %s does not exist\n\n',filename);
  else
	if strcmp(Func,'who'),
	  tmp = feval(Func,'-file',filename);
	  fprintf('%s(%3d): ', g,ExpNo);
      if ~isempty(VarName),
        for K=1:length(tmp),
          if any(find(strcmp(tmp{K},VarName))),
            fprintf('%s ', tmp{K});
          end;
        end;
      else
        fprintf('%s ',tmp{:});
      end;
	  fprintf('\n');
	else
	  fprintf('%s(%3d)\n', g,ExpNo);
	  feval(Func,'-file',filename);
	  fprintf('\n');
	end;
  end
end;

if LOG,
  diary off;
  edit(InfoFile);
end;
