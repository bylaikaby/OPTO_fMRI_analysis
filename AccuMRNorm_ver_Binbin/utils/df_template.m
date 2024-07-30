%DF_TEMPLATE - Template for creating description files
%
% EXPERIMENTS : 104
% ROIS :  Brain V1 V2 XS
%
% NOTES   : no physiology
%
% GROUPS: 
%   List groups
%
% DATE and AUTHOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% basic information : data directories, session quality
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SYSP.DataNeuro	= '//Win49/M/DataNeuro/';
SYSP.DataMri	= '//Wks8/guest/nmr/';
SYSP.dirname	= 'J02.x31';
SYSP.date		= '08.Aug.05';

%=======================================================================
% CATEGORIES (CTG) OF EXPS/GROUPS/SIGS, if exist or needed
%=======================================================================
CTG.GrpPhysSigs  = {};
CTG.GrpImgSigs  = {'roiTs'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% default analysis parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ANAP.Quality                = 80;   % Percent (all exps good activation)
ANAP.ImgDistort             = 1;    % EPI-Ana can't be regist. due2distortions
ANAP.PreTime                = 16;   % Allow pre time when selecting stim for sigsort
ANAP.PostTime               = 36;   % Allow post time when selecting stim for sigsort 
ANAP.aval                   = 0.01; % Type II error for the statistical tests
ANAP.bonferroni             = 0;    % Bonferroni Correction

ANAP.mareats.IEXCLUDE       = {'V1';'V2';'XS'};    % Exclude in MAREATS
ANAP.mareats.ICONCAT        = 1;            % 1= concatanate ROIs before creating roiTs
ANAP.mareats.IFFTFLT        = 0;
ANAP.mareats.IARTHURFLT     = 0;
ANAP.mareats.IMIMGPRO       = 0;
ANAP.mareats.ICUTOFF        = 0;
ANAP.mareats.ICUTOFFHIGH    = 0;
ANAP.mareats.ICORANA        = 1;
ANAP.mareats.ITOSDU         = 2;
ANAP.mareats.IPLOT          = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROI for MRI experiments, if exist or needed, then put here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROI.groups			= {'all'};
ROI.names			= {'Brain','V1','V2','XS'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Anatomy scans (if exist gefi/mdeft/ir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ASCAN.mdeft{1}.info            = '';
ASCAN.mdeft{1}.scanreco        = [4 1];
ASCAN.mdeft{1}.imgcrop         = [40 96 180 128];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control Scans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CSCAN.epi13{1}.info         = 'Polars';
CSCAN.epi13{1}.ana          = {'';1};
CSCAN.epi13{1}.scanreco     = [3 1];
CSCAN.epi13{1}.imgcrop      = [20 48 90 64];
CSCAN.epi13{1}.v            = {[1 0 1 0 1 0 1 0]};
CSCAN.epi13{1}.t            = {[8 8 8 8 8 8 8 8]};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default Group Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GRPP.daqver         = 2.00;		% DAQ program version: 2=nl+ym; 1=nl;
GRPP.imgcrop        = [20 48 90 64];	% x, y, width, height
GRPP.ana            = {'mdeft';1;[56 60 64 68 72]};
GRPP.hwinfo         = '';		% hardware info
GRPP.grproi         = 'RoiDef';	% the name of a Group's ROI; RoiDef is the default

MULT_REGRESSION_ANALYSIS=0;
if MULT_REGRESSION_ANALYSIS,
  ANAP.mareats.IEXCLUDE       = {'V1','V2','XS'};    % Exclude in MAREATS
  GRPP.v              = {[0 1 2 0];[0 1 0];[0 1 2 0]};
  GRPP.t              = {[20 44 44 20];[20 88 20];[20 44 44 20]};
  GRPP.pVal           = 0.001;
  GRPP.ConVector      = {[1 0 0 0]; [0.7 0.5 0 0]; [0.7 0.5 1 0]};
  GRPP.model          = {'hemo';'pulses';'pulses'};
  GRPP.modelname      = {'pulse';'adapt';'adapt-rebound'};
else
  ANAP.mareats.IEXCLUDE       = {'Brain'};    % Exclude in MAREATS
  GRPP.v              = {[0 1 2 0]};
  GRPP.t              = {[20 44 44 20]};
  GRPP.pVal           = 0.001;
  GRPP.ConVector      = {[1 0 0 0]};
  GRPP.model          = {'pulses'};
  GRPP.modelname      = {'pulse'};
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% experiment groups
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GRP.MySpecialGroup.exps    = [1 9 17 25 33 41 49 57 65 73 81 89 97];
GRP.MySpecialGroup.expinfo = {'imaging'}; 
GRP.MySpecialGroup.stminfo = 'GP adapt C-C';
GRP.MySpecialGroup.stmtypes= {'blank','Conc-w0','Conc-w0','blank'};

%=======================================================================
% Individual files (must cover all 'exps'.)
%=======================================================================
for N = 1:80
  EXPP(N).physfile  = sprintf('FILENAME.adfw',N);
  EXPP(N).scanreco  = [SCAN_NUMBER, 1];
end

