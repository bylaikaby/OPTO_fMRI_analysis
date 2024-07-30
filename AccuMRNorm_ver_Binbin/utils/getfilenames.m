function fn=getfilenames(SESSION,ExpNo)
%GETFILENAMES - returns relevant dirs/files for a given experiment ExpNo
%	fn = GETFILENAMES(SESSION,ExpNo) gets dirs/filenames for a given platform
%	EXAMPLE DIRECTORIES
%
%	HOSTNAME: 'win58'
%	homedir: 'y:/mri/'
%	mridir: 'z:/DATA/nmr/'
%	physdir: 't:/DataNeuro/'
%	matdir: 'y:/DataMatlab/'
%	sesdir: 'y:/mri/matlab/ana/'
%	NKL, 25.12.01

Ses = goto(SESSION);
EXPP = Ses.expp(ExpNo);

if isfield(Ses.expp(ExpNo),'physfile') & ~isempty(Ses.expp(ExpNo).physfile),
  [n,n1,n2] = fileparts(Ses.expp(ExpNo).physfile);
else
  if isfield(Ses.expp(ExpNo),'evtfile') & ~isempty(Ses.expp(ExpNo).evtfile),
    [n,n1,n2] = fileparts(Ses.expp(ExpNo).evtfile);
  else
    % no way to get evt/adfw, then name by session and ExpNo
    n1 = sprintf('%s_%03d',lower(Ses.name),ExpNo);
    n2 = '';
  end
end


fn.sesname			= Ses.name;
fn.sesdir			= Ses.sysp.dirname;
fn.workspace		= strcat(Ses.sysp.matdir,'workspace');
fn.root				= n1;
fn.ext				= n2;

if ~strcmp(Ses.sysp.HOSTNAME,'win45'),
	Ses.sysp.physdir = Ses.sysp.DataNeuro;
	Ses.sysp.mridir = Ses.sysp.DataMri;
end;
fn.physdir = strcat(Ses.sysp.physdir,Ses.sysp.dirname);
fn.imgdir = strcat(Ses.sysp.mridir,Ses.sysp.dirname);

if 0,
if ~exist(fn.physdir,'file'),
	fprintf('WARNING: getfilenames(ERROR): %s does not exist\n',fn.physdir);
end;

if ~exist(fn.imgdir,'file'),
	fprintf('WARNING: getfilenames(ERROR): %s does not exist\n',fn.imgdir);
end;
end;

curdir = pwd;
[stat,mess,messid] = mkdir(Ses.sysp.matdir,Ses.sysp.dirname);
if stat,
   fn.matdir = strcat(Ses.sysp.matdir,Ses.sysp.dirname);
else,
   fn.matdir = curdir;
end;

fn.tmpdir = strcat(Ses.sysp.matdir,'tmp');
[stat,mess,messid] = mkdir(Ses.sysp.matdir,'tmp');
if ~stat,
   fprintf('Directory %s was created!\n',fn.tmpdir);
end;

fn.physfile	= strcat(fn.physdir,'/',fn.root,fn.ext);
fn.adxfile	= strcat(fn.matdir,'/',fn.root,'.adx');
fn.evtfile  = strcat(fn.physdir,'/',fn.root,'.dgz');
fn.stmfile  = strcat(fn.physdir,'/stmfiles/',fn.root,'.stm');
fn.pdmfile  = strcat(fn.physdir,'/stmfiles/',fn.root,'.pdm');
fn.hstfile  = strcat(fn.physdir,'/stmfiles/',fn.root,'.hst');
if isfield(EXPP,'scanreco'),
  imgfile = sprintf('%d/pdata/%d/2dseq', EXPP.scanreco);
else
  imgfile = 'none';
end;
fn.imgfile  = strcat(fn.imgdir,'/',imgfile);
fn.matfile  = strcat(fn.matdir,'/',n2,'.mat');
