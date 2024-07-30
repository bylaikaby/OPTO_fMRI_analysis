function sesinfo(SESSION,DETAIL)
%SESINFO - Display information for each group of a session using raw data
%	SESINFO(SESSION) Reads the session description file and display
%	all important information of a session. It includes, filenames,
%	experiments, image and neurophsyiology parameters etc.
%	NKL 13.02.03
%
%	See also SESHELP CLNHELP

% MAKE FORMAT COMPACT AND CLEAR THE SCREEN IN CASE PRINTING IS REQUIRED
if nargin < 2,
  DETAIL=0;
end;

if ischar(SESSION) & strncmp(SESSION,'x',1),
  SESSION = feval(SESSION);
end;

if iscell(SESSION),
  for N=1:length(SESSION),
    ses = SESSION{N}{2};
    grpnames = getgrpnames(ses);
    exps = validexps(ses);
    grpN(N) = length(grpnames);
    fprintf('[%s]: Groups(%d)=<', ses, grpN(N));;
    for K=1:length(grpnames),
      fprintf('%s ',grpnames{K});
    end;
    expN(N) = length(exps);
    fprintf('\b>, NoExp = %d\n', expN(N));
  end;
  fprintf('Sessions: %d, Groups: %d, Exps: %d\n', N, sum(grpN), sum(expN));
  return;
end;

Ses = goto(SESSION);
grpnames = getgrpnames(Ses);
fprintf('%% NAME: %s\n', Ses.name);
fprintf('%% DATE: %s\n', Ses.date);
fprintf('%% EXPERIMENTS: %d\n', length(Ses.expp));
fprintf('%% GROUPS: \n');
fprintf('%%\t%s %s %s %s %s %s \n',grpnames{:});
fprintf('\n')
if isfield(Ses,'roi'),
  fprintf('%% ROIS: \n')
  fprintf('%%\t%s %s %s %s %s %s \n',Ses.roi.names{:});
  fprintf('\n')
end
if isfield(Ses,'ascan') & ~isempty(Ses.ascan),
  fprintf('%% ANATOMICAL SCANS: \n')
  tmp = fieldnames(Ses.ascan);
  fprintf('%%\t%s %s %s %s %s %s \n',tmp{:});
  fprintf('\n')
end
if isfield(Ses,'cscan') & ~isempty(Ses.cscan),
  fprintf('%% CONTROL FUNCTIONAL SCANS: \n')
  tmp = fieldnames(Ses.cscan);
  fprintf('%%\t%s %s %s %s %s %s \n',tmp{:});
  fprintf('\n');
end
for N=1:length(grpnames),
  grp = getgrpbyname(Ses,grpnames{N});
  exps = sprintf('%d ', grp.exps);
  fprintf('%s = [%s]\n', grpnames{N}, exps);
end;

exps = validexps(Ses);
exps = sort(exps);
savename = 'none';
for N=1:length(exps),
  ExpNo = exps(N);
  grp=getgrp(Ses,ExpNo);
  if ~strcmp(savename,grp.name),
    fprintf('======================================\n');
    savename = grp.name;
  end;
  fprintf('%12s [%3d] <scan=%3d> - %s\n',...
          upper(grp.name), ExpNo, Ses.expp(ExpNo).scanreco(1), Ses.expp(ExpNo).physfile);
end;

if ~DETAIL,
  return;
end;


format compact;
close all; clc;
InfoFile = strcat('INFO_',Ses.name,'.log');
diary off;
diary(InfoFile);

fprintf('SESSION: %s\n', Ses.name);
fprintf('DIRECTORY: %s\n', Ses.sysp.dirname);
tmp=fieldnames(Ses.grp)';
fprintf('Groups: ');
for N=1:length(tmp),
  fprintf('%s; ', tmp{N});
end;
fprintf('\n');
fprintf('Roi Names: ');
for N=1:length(Ses.roi.names),
  fprintf('%s; ', Ses.roi.names{N});
end;
fprintf('\n');
if isfield(Ses,'roimodel');
  fprintf('Roi Model: %s\n', Ses.roi.models);
end;

for N=1:length(Ses.expp),
  if ~isempty(Ses.expp(N).scanreco),
	fprintf('Exp(%3d): %s; Scan: %3d\n',N,Ses.expp(N).physfile,...
			Ses.expp(N).scanreco(1));
  else
	fprintf('Exp(%3d): %s; NO-SCAN\n',N,Ses.expp(N).physfile);
  end;
end;

fprintf('\nINDIVIDUAL GROUP INFORMATION\n');
grps = getgroups(Ses);

for G=1:length(grps),
	grps{G}
	ExpNo = grps{G}.exps(1);
	fn = getfilenames(Ses,ExpNo);
	if isimaging(grps{G}),
	  fprintf('\nGROUP(%s): IMAGING INFORMATION\n',grps{G}.name);
	  pv = getpvpars(Ses,ExpNo)
	end;

	if isrecording(grps{G}),
	  fprintf('\nGROUP(%s): ADF FILE INFORMATION\n',grps{G}.name);
	  fprintf('Directory: %s\n', fn.physdir);
	  fprintf('ADF File: %s\n', fn.physfile);
	  [chan,obsp,sampt,obslen] = adf_info(fn.physfile);
	  fprintf('Chan,Obsp,DT_msec,obslen = %d, %d, %6.4f, %d',...
			  chan,obsp,sampt,obslen);
	end;

	if exist(fn.evtfile,'file'),
	  fprintf('\nGROUP(%s): EVENT FILE INFORMATION\n',grps{G}.name);
	  fprintf('Event File: %s\n', fn.evtfile);
	  evt = expgetevt(Ses, ExpNo);		% Get events from dgz file
	  fprintf('BEGIN: %d\n', evt.obs{1}.times.begin);
	  fprintf('END: %d\n', evt.obs{1}.times.end);
	  fprintf('First 5 MRI Events: ');
	  fprintf('%8d ',evt.obs{1}.times.mri(1:5));
	end;
	
end;
fprintf('\n\n\n');
diary off;
edit(InfoFile);




