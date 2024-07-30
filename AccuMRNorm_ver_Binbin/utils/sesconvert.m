function sesconvert(Ses,varargin)
%SESCONVERT - Converts data structure to the latest one.
%  SESCONVERT(SES,...) converts data structure to the latest one.
%
%  NOTE :
%    This function supports only from ver1 to ver2.
%
%  EXAMPLE :
%    sesconvert(session)
%
%  VERSION :
%    0.90 31.01.12 YM  pre-release
%    0.91 03.02.12 YM  separated glm/cor data.
%    0.92 07.02.12 YM  bug fix for anatomy.
%    0.93 03.03.12 YM  supports 'tripilot', 'mask'.
%    0.94 03.07.12 YM  saves "evt" as "nevt" to avoid dgz conflict.
%    0.95 08.08.12 YM  ignore "evt" if "nevt" exists.
%    0.96 10.09.12 YM  ignore "SIGS/Copy of XXX.mat".
%    0.97 18.01.13 YM  supports 'mroiatlas_tform'.
%    0.98 05.06.13 YM  '-v7.3' to save.
%
%  See also getses sesversion sigfilename sigfilename_ver1 sesconv2hdf5

if nargin == 0,  eval(['help ' mfilename]); return;  end

Ses = goto(Ses);
if isa(Ses,'mcsession'),
  Ses = Ses.oldstruct();
end


tStart = tic;
% SESSION/SIGS/sesname*.mat : tcImg/Cln/ClnSpc
fprintf('%s %s === tcImg ==================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_sigdir(Ses,'tcImg',1);
fprintf('%s %s ==== Cln ===================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_sigdir(Ses,'Cln',1);
fprintf('%s %s === ClnSpc =================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_sigdir(Ses,'ClnSpc',1);
if exist('SIGS','dir'),
  try
  rmdir('SIGS');
  catch
  end
end

% SESSION/ExpPar.mat
fprintf('%s %s === SesPar =================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_exppar(Ses,'SesPar.mat');

% SESSION/ClnAdjEvt.mat
fprintf('%s %s === ClnAdjEvt ==============================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_exppar(Ses,'ClnAdjEvt.mat');

% SESSION/Roi.mat
fprintf('%s %s ==== Roi ===================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_roi(Ses);

% SESSION/anatomy.mat
fprintf('%s %s ==== Ana ===================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_ana(Ses);

% SESSION/grpname.mat
fprintf('%s %s ==== Grp ===================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_group(Ses);

% SESSION/sesname*.mat
fprintf('%s %s ==== Exp ===================================\n',datestr(now,'HH:MM:SS'),mfilename);
sub_export_mat(Ses);


tElapsed = toc(tStart);
fprintf('\n%s %s: %gs(%gmin)\n',datestr(now,'HH:MM:SS'),mfilename,tElapsed,tElapsed/60);

fprintf('\n !!! Edit ''%s.m'' by adding ''SYSP.VERSION = 2.0;''\n',Ses.name);


return


% ===============================================
function sub_export_sigdir(Ses,SigName,DoOverwrite)
% ===============================================
X = dir(sprintf('SIGS/*_%s.mat',upper(SigName)));
for N = 1:length(X),
  if any(X(N).isdir),  continue;  end
  [fp fr fe] = fileparts(X(N).name);
  
  if any(strncmpi(fr,'Copy of',7)),  continue;  end
  
  ExpNo = [];
  for K = 1:length(Ses.expp)
    try
      [tmpfp tmpfr] = fileparts(sigfilename_ver1(Ses,K,SigName));
    catch
      continue
    end
    if strcmpi(fr,tmpfr),
      ExpNo = K;  break;
    end
  end
  %ExpNo = sscanf(lower(X(N).name),[lower(Ses.name) '_%d_' lower(SigName) '.mat']);
  if any(ExpNo) && length(ExpNo) == 1,
    dstfile = sigfilename(Ses,ExpNo,SigName,'version',2);
  else
    keyboard
  end
  srcfile = fullfile('SIGS',X(N).name);
  fprintf('%3d/%d %s: %s --> %s ...',N,length(X),SigName,srcfile,dstfile);  drawnow;
  tmpch = 'y';
  if exist(dstfile,'file') && ~any(DoOverwrite),
    tmpch = input('\nQ: file exists, overwrite? Y/N[Y]: ','s');
    if isempty(tmpch),  tmpch = 'y';  end
  end
  switch lower(tmpch),
   case {'y'}
    mmkdir(fileparts(dstfile));
    status = movefile(srcfile,dstfile);
    if ~status,
      keyboard
    end
  end
  fprintf(' done.\n');
end


X = dir(sprintf('SIGS/*_%s.mat.bak',upper(SigName)));
for N = 1:length(X),
  if any(X(N).isdir),  continue;  end
  [fp fr fe] = fileparts(X(N).name);
  if any(strncmpi(fr,'Copy of',7)),  continue;  end

  fr = strrep(fr,'.mat','');
  ExpNo = [];
  for K = 1:length(Ses.expp)
    [tmpfp tmpfr] = fileparts(sigfilename_ver1(Ses,K,SigName));
    if strcmpi(fr,tmpfr),
      ExpNo = K;  break;
    end
  end
  %ExpNo = sscanf(lower(X(N).name),[lower(Ses.name) '_%d_' lower(SigName) '.mat.bak']);
  if any(ExpNo) && length(ExpNo) == 1,
    dstfile = sigfilename(Ses,ExpNo,sprintf('%s.bak',SigName),'version',2);
  else
    keyboard
  end
  srcfile = fullfile('SIGS',X(N).name);
  fprintf('%3d/%d %s: %s --> %s ...',N,length(X),SigName,srcfile,dstfile);  drawnow;
  
  if exist(dstfile,'file') && ~any(DoOverwrite),
    keyboard
  else
    mmkdir(fileparts(dstfile));
    status = movefile(srcfile,dstfile);
    if ~status,
      keyboard
    end
  end
  fprintf(' done.\n');
end


return


% ===============================================
function sub_export_exppar(Ses,MATFILE)
% ===============================================
if ~exist(MATFILE,'file'), return;  end

switch lower(MATFILE)
 case { 'sespar.mat' 'sespar' }
  NewVar = 'exppar';
 case { 'clnadjevt.mat' 'clnadjevt' }
  NewVar = 'clnadj';
 otherwise
  keyboard
end

X = who('-file',MATFILE);
for N = 1:length(X),
  par = load(MATFILE,X{N});
  par = par.(X{N});
  ExpNo = sscanf(X{N},'exp%d');
  if any(ExpNo) && length(ExpNo) == 1,
    dstfile = sigfilename(Ses,ExpNo,NewVar,'version',2);
  else
    keyboard
  end
  fprintf('%3d/%d %s: %s --> %s ...',N,length(X),X{N},MATFILE,dstfile);  drawnow;
  if ~exist(dstfile,'file'),
    mmkdir(fileparts(dstfile));
    eval(sprintf('%s = par;',NewVar));
    save(dstfile,NewVar,'-v7.3');
    fprintf(' done.\n');
  else
    keyboard
  end
end

delete(MATFILE);

return



% ===============================================
function sub_export_roi(Ses)
% ===============================================
srcfile = fullfile(pwd,'mroiatlas_tform.mat');
if exist(srcfile,'file')
  dstfile = fullfile(pwd,'roi/mroiatlas_tform.mat');
  fprintf('mroiatlas: %s --> %s ...',srcfile,dstfile);  drawnow;
  if ~exist(dstfile,'file'),
    mmkdir(fileparts(dstfile));
    status = movefile(srcfile,dstfile);
    if ~status,
      keyboard
    end
    fprintf(' done.\n');
  else
    keyboard
  end
end


MATFILE = fullfile(pwd,'Roi.mat');
if ~exist(MATFILE,'file'), return;  end

X = who('-file',MATFILE);
for N = 1:length(X),
  roi = load(MATFILE,X{N});
  roi = roi.(X{N});
  dstfile = fullfile(pwd,sprintf('roi/%s_%s.mat',Ses.name,lower(X{N})));
  fprintf('%3d/%d %s: %s --> %s ...',N,length(X),X{N},MATFILE,dstfile);  drawnow;
  if ~exist(dstfile,'file'),
    mmkdir(fileparts(dstfile));
    eval(sprintf('%s = roi;',X{N}));
    save(dstfile,X{N},'-v7.3');
    fprintf(' done.\n');
  else
    keyboard
  end
end

delete(MATFILE);


return

  

% ===============================================
function sub_export_ana(Ses)
% ===============================================
if ~isfield(Ses,'ascan') || isempty(Ses.ascan),  return;  end

ananame = fieldnames(Ses.ascan);
ananame{end+1} = 'tripilot';
ananame = unique(ananame);

for N = 1:length(ananame),
 srcfile = fullfile(pwd,sprintf('%s.mat',ananame{N}));
 if ~exist(srcfile,'file'), continue;  end
 tmp = who('-file',srcfile);
 if ~all(strcmpi(tmp,ananame{N})),
   keyboard
 end
 ana = load(srcfile,ananame{N});
 ana = ana.(ananame{N});
 SigName = ananame{N};
 for X = 1:length(ana),
   dstfile = sigfilename(Ses,X,ananame{N},'version',2);
   fprintf(' %s{%d} : %s --> %s ...',ananame{N},X,srcfile,dstfile);  drawnow;
   DO_UPDATE = 1;
   if exist(dstfile,'file'),
     tmptxt = sprintf('\n Q: ''%s'' exists, overwrite? Y/N[Y]: ',dstfile);
     tmpch = input(tmptxt,'s');
     if isempty(tmpch),  tmpch = 'y';  end
     switch lower(tmpch),
      case {'y'}
       DO_UPDATE = 1;
      otherwise
       DO_UPDATE = 0;
     end
   end
   if DO_UPDATE,
     mmkdir(fileparts(dstfile));
     eval([ SigName ' = ana{X};']);
     save(dstfile,SigName,'-v7.3');
     fprintf(' done.\n');
   end
 end
 delete(srcfile);
end



return



% ===============================================
function sub_export_group(Ses)
% ===============================================
if ~isfield(Ses,'grp') || isempty(Ses.grp),  return;  end

gname = fieldnames(Ses.grp);
for N = 1:length(gname),
 srcfile = fullfile(pwd,sprintf('%s.mat',gname{N}));
 if ~exist(srcfile,'file'), continue;  end
 VarName = who('-file',srcfile);
 for X = 1:length(VarName),
   sig = load(srcfile,VarName{X});
   sig = sig.(VarName{X});

   if strcmpi(VarName{X},'mask'),
     SigName = 'mask';
     dstfile = sigfilename(Ses,gname{N},SigName,'version',2);
     fprintf(' %s(%s) : %s --> %s ...',gname{N},SigName,srcfile,dstfile);  drawnow;
     if ~exist(dstfile,'file'),
       mmkdir(fileparts(dstfile));
       eval(sprintf('%s = sig;',SigName));
       save(dstfile,SigName,'-v7.3');
       fprintf(' done.\n');
     else
       keyboard
     end
     continue;
   end
   
   [sig glmregr glmcont] = sub_getglm(sig);
   [sig corana]          = sub_getcor(sig);
   SigName = VarName{X};
   dstfile = sigfilename(Ses,gname{N},SigName,'version',2);
   fprintf(' %s(%s) : %s --> %s ...',gname{N},SigName,srcfile,dstfile);  drawnow;
   if ~exist(dstfile,'file'),
     mmkdir(fileparts(dstfile));
     eval(sprintf('%s = sig;',SigName));
     save(dstfile,SigName,'-v7.3');
     fprintf(' done.\n');
   else
     keyboard
   end
   if ~isempty(glmregr),
     fname1 = statfilename(Ses,gname{N},SigName,'glmregr','version',2);
     fname2 = statfilename(Ses,gname{N},SigName,'glmcont','version',2);
     if ~exist(fname1,'file'),
       mmkdir(fileparts(fname1));
       save(fname1,'glmregr','-v7.3');
       save(fname2,'glmcont','-v7.3');
     else
       keyboard
     end
   end
   if ~isempty(corana),
     fname = statfilename(Ses,gname{N},SigName,'corana','version',2);
     if ~exist(fname,'file'),
       mmkdir(fileparts(fname));
       save(fname,'corana','-v7.3');
     else
       keyboard
     end
   end
   
 end
 delete(srcfile);
end

return



% ===============================================
function sub_export_mat(Ses)
% ===============================================
%EXPS = 1:length(Ses.expp);
EXPS = [];
gname = fieldnames(Ses.grp);
for N = 1:length(gname),
  EXPS = cat(2,EXPS,Ses.grp.(gname{N}).exps);
end
EXPS = unique(EXPS);

for N = 1:length(EXPS),
  ExpNo = EXPS(N);
  srcfile = sigfilename_ver1(Ses,ExpNo,'mat');
  if ~exist(srcfile,'file'),  continue;  end
  VarName = who('-file',srcfile);
  % remove 'evt' if 'nevt' exists... how could this happen?
  if any(strcmpi(VarName,'evt')) && any(strcmpi(VarName,'nevt')),
    VarName = VarName(~strcmpi(VarName,'evt'));
  end
  for X = 1:length(VarName),
    sig = load(srcfile,VarName{X});
    sig = sig.(VarName{X});
    [sig glmregr glmcont] = sub_getglm(sig);
    [sig corana]          = sub_getcor(sig);
    if strcmpi(VarName{X},'evt')
      SigName = 'nevt';
    else
      SigName = VarName{X};
    end
    dstfile = sigfilename(Ses,ExpNo,SigName,'version',2);
    fprintf(' %3d/%d Exp%3d(%s) %s --> %s ...',N,length(EXPS),ExpNo,SigName,...
            srcfile,dstfile);  drawnow;
    if ~exist(dstfile,'file'),
      mmkdir(fileparts(dstfile));
      eval(sprintf('%s = sig;',SigName));
      save(dstfile,SigName,'-v7.3');
      fprintf(' done.\n');
    else
      keyboard
    end
    if ~isempty(glmregr),
      fname1 = statfilename(Ses,ExpNo,SigName,'glmregr','version',2);
      fname2 = statfilename(Ses,ExpNo,SigName,'glmcont','version',2);
      if ~exist(fname1,'file'),
        mmkdir(fileparts(fname1));
        save(fname1,'glmregr','-v7.3');
        save(fname2,'glmcont','-v7.3');
      else
        keyboard
      end
    end
   if ~isempty(corana),
     fname = statfilename(Ses,ExpNo,SigName,'corana','version',2);
     if ~exist(fname,'file'),
       mmkdir(fileparts(fname));
       save(fname,'corana','-v7.3');
     else
       keyboard
     end
   end
  end
  delete(srcfile);
end

return


% GLM BEGIN ================================================================
function [sig glmregr glmcont] = sub_getglm(sig)
glmregr = {};  glmcont = {};
if ~sub_is_glmsig(sig),  return;  end
[sig glmregr glmcont] = sub_sep_glmsig(sig);
return

function v = sub_is_glmsig(sig)
v = 0;
if iscell(sig),
  for N = 1:length(sig),
    v = sub_is_glmsig(sig{N});
    if any(v);  break;  end
  end
  return
end
if isfield(sig,'glmoutput') && isfield(sig,'glmcont'),
  v = 1;
end
return

function [sig glmregr glmcont] = sub_sep_glmsig(sig)
if iscell(sig)
  for N = 1:length(sig),
    [sig{N} glmregr{N} glmcont{N}] = sub_sep_glmsig(sig{N});
  end
  return;
end

glmregr.session   = sig.session;
glmregr.grpname   = sig.grpname;
glmregr.ExpNo     = sig.ExpNo;
try
glmregr.base      = sig.dir.dname;
catch
  keyboard
end
if isfield(sig,'glmoutput'),
  glmregr.glmoutput = sig.glmoutput;
  sig = rmfield(sig,'glmoutput');
else
  glmregr.glmoutput = [];
end

glmcont.session   = sig.session;
glmcont.grpname   = sig.grpname;
glmcont.ExpNo     = sig.ExpNo;
glmcont.base      = sig.dir.dname;
if isfield(sig,'glmcont'),
  glmcont.glmcont = sig.glmcont;
  sig = rmfield(sig,'glmcont');
else
  glmcont.glmcont = [];
end
return
% GLM END ==================================================================



% COR BEGIN ================================================================
function [sig corana] = sub_getcor(sig)
corana = {};
if ~sub_is_corsig(sig),  return;  end
[sig corana] = sub_sep_corsig(sig);
return

function v = sub_is_corsig(sig)
v = 0;
if iscell(sig),
  for N = 1:length(sig),
    v = sub_is_corsig(sig{N});
    if any(v);  break;  end
  end
  return
end
if isfield(sig,'r') && isfield(sig,'p') && iscell(sig.r) && iscell(sig.p),
  if ~isempty(sig.r) && length(unique(sig.r{1})) > 1,
    v = 1;
  end
end
return

function [sig corana] = sub_sep_corsig(sig)
if iscell(sig)
  for N = 1:length(sig),
    [sig{N} corana{N}] = sub_sep_corsig(sig{N});
  end
  return;
end

corana.session   = sig.session;
corana.grpname   = sig.grpname;
corana.ExpNo     = sig.ExpNo;
corana.base      = sig.dir.dname;
if isfield(sig,'r'),
  corana.r       = sig.r;
  corana.p       = sig.p;
  sig = rmfield(sig,{'r' 'p'});
end
if isfield(sig,'mdl')
  corana.mdl     = sig.mdl;
  sig = rmfield(sig,'mdl');
end
return
% COR END ==================================================================
