function ses = getses(SessionName,VERBOSE)
%GETSES - Set up Ses structure with all session's parameters
%	ses = GETSES(SessionName,VERBOSE)
%	SessionName: Name of session, e.g.b00401
%	VERBOSE = 0: only logo is displayed
%	VERBOSE =-1: fprintf information
%	VERBOSE = 1: suppress logo
%	ses: ses.sysp, ses.acqp, ses.expp, ses.anap etc.....
%	Functions used:
%	ses.sysp		= getdirs;				* platform specific information
%	ses.acqp.evt	= getevtcodes;			* hard-coded events
%	ses.anap		= getanap('default')	* analysis parameters
%
%         name: 'm02lx1'
%         acqp: [1x1 struct]
%                       add to acqp the dirname: 'M02.lx1'
%         sysp: [1x1 struct]
%               DataNeuro: '//Win49/E/DataNeuro/'
%               DataMri: '//Wks8/guest/nmr/'
%         anap: [1x1 struct]
%               add to anap
%                   Quality: 100
%                   revcor: [1x1 struct]
%                   confunc: [1x1 struct]  
%        ascan: [1x1 struct]
%        cscan: [1x1 struct]
%          roi: [1x1 struct]
%         expp: [1x53 struct]
%          grp: [1x1 struct]
%          ctg: [1x1 struct]
%          expp:
%
% See also GOTO, GETDIRS, GETEVTCODES, GETANAP, GETACQP
%
% NKL, 05.10.02
% YM,  02.02.04  ses.anap will be given by getanap.
% YM,  16.08.05  potential bug fix of ses.anap.
% YM,  20.12.05  use subMergeStruct().
% YM,  08.01.06  subMergeStruct() can support structure arrays.

if nargin < 2,	VERBOSE = 0; end;

if VERBOSE == 1,
  disp('getses: NKL 05.10.02');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evaluate session file and get session/analysis info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ACQP  = {};  SYSP  = {};  ANAP = {};
ASCAN = {};  CSCAN = {};  ROI  = {};
GRPP  = {};  GRP   = {};  CTG   = {};  EXPP = {};
% If no session file was specified, ask for one.
if nargin < 1,
  DIRS = getdirs;
  [filename,pathname] = uigetfile(strcat(DIRS.sesdir,'*.m'),...
                                  'Select a session file.');
  if isequal(filename,0) | isequal(pathname,0),
    fprintf('getses: no session file was selected.\n');
    ses = {};
    return;
  end
  SessionName = strrep(filename, '.m', '');
  tmpDir = cd;				% Store cur dir.
  cd(pathname);
  eval(SessionName);
  cd(tmpDir);
else
  SessionName = strrep(SessionName,'.','');  % to allow M02.lx1 style
  % Matlab7 warns upper/lower case of 'SessionName',
  % use which() function to suppers that messesage.
  SessionFile = which(sprintf('%s.m',SessionName));
  if isempty(SessionFile),
    error('getses: SesFile %s does not exist!\n',strcat(SessionName,'.m'));
    ses = {};
    return;
  end;
  [pathstr,SessionName,extstr] = fileparts(SessionFile);
  eval(SessionName);
end;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initiaize 'ses' structure.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ses.name	= lower(SessionName);
ses.date	= lower(SYSP.date);
ses.acqp 	= getacqp;
ses.sysp	= getdirs;
ses.anap	= getanap('default');	% get default analysis parameters
ses.ascan	= ASCAN;
ses.cscan	= CSCAN;
ses.roi		= ROI;
ses.grp		= GRP;
ses.ctg		= {};  % set later
ses.expp	= EXPP;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SYSP PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% overwrite with SYSP of the session file.
if isa(SYSP,'struct'),
  ses.sysp = subMergeStruct(ses.sysp,SYSP);
end

switch lower(ses.sysp.HOSTNAME),
 case {'win45','win10'}
  % Nikos's laptop
  if isfield(ses,'DVD') & ses.DVD,
	ses.sysp.DataMri = 'e:/';
	ses.sysp.DataNeuro = 'e:/';
  end
end;

% overwrite those.
if isfield(ses.sysp,'DataNeuro') & ~isempty(ses.sysp.DataNeuro),
  ses.sysp.physdir = ses.sysp.DataNeuro;
end;
if isfield(ses.sysp,'DataMri') & ~isempty(ses.sysp.DataMri),
  ses.sysp.mridir = ses.sysp.DataMri;
end;
if isfield(ses.sysp,'DataMatlab') & ~isempty(ses.sysp.DataMatlab),
  if isfield(ses.sysp,'IgnoreSYSPDataMatlab') & any(ses.sysp.IgnoreSYSPDataMatlab),
    % ignore SYSP.DataMatlab, and use settings in getdirs.m
  else
    ses.sysp.matdir = ses.sysp.DataMatlab;
  end
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ANAP PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% overwrite with ANAP of the session file
% Definitions related to correlation or GLM analysis
ANAP.aval               = 0.50;         % p-value for selecting time series
ANAP.rval               = 0.05;         % r (Pearson) coeff. for selecting time series
ANAP.shift              = 1;            % nlags for xcor in seconds
ANAP.clustering         = 1;            % apply clustering after voxel-selection
ANAP.bonferroni         = 0;            % Correction for multiple comparisons

ANAP.mview.viewmode     = 'lightbox-trans';
ANAP.mview.anascale     = [0  20000  1];
ANAP.mview.roi          = 'brain';
ANAP.mview.alpha        = 0.01;
ANAP.mview.statistics   = 'none';
ANAP.mview.glmana.model = 1;
ANAP.mview.glmana.trial = 1;
ANAP.mview.cluster      = 1;
ANAP.mview.negcorr      = 1;
ANAP.mview.mcluster3.B  = 3;
ANAP.mview.mcluster3.cutoff     =  round((2*(ANAP.mview.mcluster3.B-1)+1)^3*0.3);
ANAP.mview.bwlabeln.conn        = 26;	% must be 6(surface), 18(edges) or 26(corners)
ANAP.mview.bwlabeln.minvoxels   = ANAP.mview.bwlabeln.conn * 0.8;

% Definitions regarding sorting by trial
GRPP.anap.gettrial.status       = 0;
GRPP.anap.gettrial.Xmethod      = 'zerobase'; % tosdu-prestim doesn't show anything,
GRPP.anap.gettrial.Xepoch       = 'prestim';% Argument (Epoch) to xfrom in gettrial
GRPP.anap.gettrial.Xepoch       = 'blank';  % Argument (Epoch) to xfrom in gettrial
GRPP.anap.gettrial.RefChan      = 2;        % Reference channel (for DIFF)
GRPP.anap.gettrial.sort         = 'trial';  % sorting with SIGSORT, can be 'none|stimulus|trial
GRPP.anap.gettrial.Average      = 1;        % Concat/Average; It is also used from trial2obsp
GRPP.anap.gettrial.trial2obsp   = 1;        % If set, it cat(1,..) the signals
GRPP.anap.HemoDelay             = 2;
GRPP.anap.HemoTail              = 2;

if isa(ANAP,'struct'),
  ses.anap = subMergeStruct(ses.anap,ANAP);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CTG PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ===========================================================================
% DEFAULT BLPs AND TO BE GROUPED SIGNALS
% Lfp [1 90] unrectified
% Gamma [24 90] unrectified
% LfpL/M/H Rectified in [1-12, 12-24, 24-90]
% MUA/SDF
% ===========================================================================

% SIGNALS USED FOR COMPUTING TRIAL STATISTICS
ses.ctg.StatSigs = {'Lfp'; 'Gamma';'LfpH';'Mua';'Sdf'};

% SIGNALS USED FOR COMPUTING RFs WITH REVERSE CORRELATION
ses.ctg.RFSigs		= {'LfpH';'Mua';'Sdf'};

% SIGNALS USED FOR THE DEPENDENCY ANALYSIS
% THE FMRI SIGNALS ARE ALL TO BE FOUND UNDER roiTs. THIS STRUCTURE
% CONTAINS ALL THE AREAS/ROIS THAT WILL BE TESTED FOR INTERVOXEL
% INDEPENDENCE.
ses.ctg.SigBands	= {'Lfp', 'Gamma', 'Mua', 'Sdf'};

% SPECIAL NEURAL GROUPING FOR RF-FIELDS, AND DEPENDENCE SIGNALS
ses.ctg.GrpDepend   = {'Gamma';'LfpM';'LfpH';'Mua';'Sdf';'roiTs'};
ses.ctg.GrpRFSigs	= {'VLfpH3';'VMua3';'VSdf3'};
ses.ctg.GrpDEPSigs	= {'kc2mua';'cr2mua';'ch2mua';...
                    'cr2LM';'cr2LMt';'cr2LMbp';'cr2LMbp20';'cr2LMwin';...
                    'cr2LMtenv';'cr2LMenv';'cr2LMar';'cr2LMtar';'cr2LMtarenv';'cr2LMtenvn';'cr2LMtdcrfeat';...
					'cr2sdf';'ch2sdf';'kc2sdf';...
                    'kc1';'kc2';'kc2cor';'kc2hor';'kc2ver';...
                    'minew1';'minew2';'gr1';'gr2';...
                    'ch1';'ch2';'cr1';'cr2';'cr2hor';'cr2ver';'depzero';...
                    'blpcoh';'blpcor';'blpcov';'cr1nv';'minew1nv';'crdepzero';'cr2LMmovrf';'crb2b';'minewb2b';'cftr';'cfdb'};


% SPECIAL PHYSIOLOGY SIGNAL-GROUPING
ses.ctg.GrpPhySigs  = {'blp'};

% SPECIAL FMRI SIGNAL-GROUPING
ses.ctg.GrpImgSigs	= {'roiTs'};

% SIGNALS USED TO EXTRACT TRIALS
ses.ctg.TrialSigs	= {'blp';'roiTs'};

% overwrite with CTG of the session file
if isa(CTG,'struct'),
  fnames = fieldnames(CTG);
  for N = 1:length(fnames),
    cmdstr = sprintf('ses.ctg.%s = CTG.%s;',fnames{N},fnames{N});
    eval(cmdstr);
  end
  % take care of the session file having CTG.imgGrp instead of CTG.ImgGrp.
  if isfield(ses.ctg,'imgGrps'),
    ses.ctg.ImgGrps = ses.ctg.imgGrps;
    ses.ctg = rmfield(ses.ctg,'imgGrps');
  end
end

% SET DEFAULT GROUP PARAMETERS, IF NEEDED.
if isa(GRPP,'struct') & isa(ses.grp,'struct'),
  grpnames = fieldnames(ses.grp);
  for N = 1:length(grpnames),
    tmpgrp = subMergeStruct(GRPP,ses.grp.(grpnames{N}));
    ses.grp.(grpnames{N}) = tmpgrp;
  end
end

if VERBOSE == -1,
  ses.sysp
  ses.acqp.evt
end;


return;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to merget structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sctC = subMergeStruct(sctA, sctB)

try,
sctC = sctA;
fnames = fieldnames(sctB);
for N = 1:length(fnames),
  tmpname = fnames{N};
  if isstruct(sctB.(tmpname)) & isfield(sctC,tmpname),
      sctC.(tmpname) = subMergeStruct(sctC.(tmpname),sctB.(tmpname));
  else
    sctC.(tmpname) = sctB.(tmpname);
  end
end
catch,
  lasterr
  fprintf('\n %s: some errors in the session file...\n',mfilename);
  keyboard
end

return;
