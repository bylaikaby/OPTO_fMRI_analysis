function anap = getanap(varargin)
%GETANAP - Returns default analysis parameters
%  ANAP = GETANAP(SESSION,ExpNo/GrpName) returns analysis paramaters 
%  for the given ExpNo/GrpName, overwritin defalut values by ANAP and 
%  GRP.xxx.anap of the session file.
%  SESSION/GrpName can be a structure returned by GOTO/GETGRP function.
%
%  ANAP = GETANAP(SESSION) returns analys parameters for the given
%  session, overwriting default values by ANAP only, no GRP.xxxx.anap.
%
%  ANAP = GETANAP('default') returns default values.
%
%  NOTE :
%   The session description file can have analysis parameters as
%   ANAP, GRPP.anap and/or GRP.xxx.anap.
%   If session is given to this function, then default parameters will be overwritten by
%   ANAP.  If ExpNo or GrpName is given, then values will be
%   again overwritten by GRP.xxx.anap.
%
% PRIORITY : GRP.xxx.anap > ANAP > anap
%   the highest is 'GRP.xxx.anap' in the session file.
%   the next one is 'ANAP' in the session file.
%   the lowest is 'anap' below in this file.
%
% VERSION :
%   0.90 24.01.04 YM  derived from utils/getses.m.
%   0.91 21.12.05 YM  bug fix, clean up.
%   0.92 07.07.09 YM  bug fix
%   0.93 30.01.12 YM  supports mcsession.
%   0.95 13.05.13 YM  disabled old parameters, which may conflict with new ones.
%
% See also GETSES GETBANDSFLT GETLFPMUA

  
if nargin == 0, help getanap;  return;  end


% CONTRARST TESTED IN OUR DEPENDENCE STUDY
anap.contrasts = {'kc'; 'minew'; 'gr'; 'kcca'; 'mi'; 'kgv'; 'kmi'};
             
% DEFAULT VALUES FOR ANALYSIS PARAMETER
%% THE OLD LIMITS WE USED FOR THE NATURE 2001 PAPER
if 0,
  anap.bands.lfp1	= [30 100];
  anap.bands.lfp	= [20 150];
  anap.bands.mua1	= [500 2500];
  anap.bands.mua	= [300 1500];
  anap.bands.tot	= [10 2500];

  anap.eeg{1} = [1 4];
  anap.eeg{2} = [4 8];
  anap.eeg{3} = [8 12];
  anap.eeg{4} = [12 24];
  anap.eeg{5} = [24 90];
  anap.eeg{6} = [4 99];
  anap.eeg{7} = [150 400];
  anap.eeg{8} = [400 2500];

  %% WHEN WE FILTER WE USE:
  %% THIS IS DEFAULTS OF DEFAULTS AND CAN BE OVERWRITTEN BY ses.anap
  %% IN THE DISCRIPTION FILE.
  %anap.bands.Lfp        = [1 90];		% entire "lfp" range
  anap.bands.Lfp        = [1 150];		% entire "lfp" range
  anap.bands.GammaL     = [24 35];		% gamm "lfp" range (unrectified)
  anap.bands.GammaM     = [35 80];		% delta-theta (envelop)
  anap.bands.GammaH     = [80 100];		% alpha-beta (envelop)
  anap.bands.Mid        = [100 400];		% gamma (envelop)
  anap.bands.Mua        = [500 3000];	% spiking
  %anap.bands.Mua        = [500 2500];	% spiking
  anap.bands.lfpcutoff  = 10;			% Low pass filter after rectification
  anap.bands.muacutoff  = 100;			% Low pass filter after rectification
  anap.bands.samprate   = 250;			% Resample at 250Hz
  anap.bands.sdfkernel  = 0.025;        % Kerenel size 25ms
  anap.bands.conv2sdu   = 1;			% Convert to SDU

  % for backward compatibility
  anap.bands.LfpL       = [1 12];		% delta-theta (envelop)
  anap.bands.LfpM       = [12 24];		% alpha-beta (envelop)
  anap.bands.LfpH       = [24 90];		% gamma (envelop)
  anap.bands.Gamma      = [24 90];		% gamm "lfp" range (unrectified)
end;



% gettrial stuff
anap.gettrial.status    = 0;
%anap.gettrial.Xmethod   = 'tosdu';  % Argument (Method)to xfrom in gettrial
%anap.gettrial.Xepoch    = 'prestim';% Argument (Epoch) to xfrom in gettrial
%anap.gettrial.Average   = 1;        % Do not average tblp, but concat
%anap.gettrial.RefChan   = 2;        % Reference channel (for DIFF)
%anap.gettrial.sort      = 'trial';  % sorting with SIGSORT, can be 'none|stimulus|trial



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ANAP PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% overwrite with ANAP of the session file
% Definitions related to correlation or GLM analysis
anap.aval               = 0.50;         % p-value for selecting time series
anap.rval               = 0.05;         % r (Pearson) coeff. for selecting time series
anap.shift              = 1;            % nlags for xcor in seconds
anap.clustering         = 1;            % apply clustering after voxel-selection
anap.bonferroni         = 0;            % Correction for multiple comparisons

anap.mview.viewmode     = 'lightbox-trans';
anap.mview.anascale     = [0  20000  1];
anap.mview.roi          = 'brain';
anap.mview.alpha        = 0.01;
anap.mview.statistics   = 'none';
anap.mview.glmana.model = 1;
anap.mview.glmana.trial = 1;
anap.mview.cluster      = 1;
anap.mview.negcorr      = 1;
anap.mview.mcluster3.B  = 3;
anap.mview.mcluster3.cutoff     =  round((2*(anap.mview.mcluster3.B-1)+1)^3*0.3);
anap.mview.bwlabeln.conn        = 26;	% must be 6(surface), 18(edges) or 26(corners)
anap.mview.bwlabeln.minvoxels   = anap.mview.bwlabeln.conn * 0.8;

% Definitions regarding sorting by trial
anap.gettrial.status       = 0;
anap.gettrial.Xmethod      = 'zerobase'; % tosdu-prestim doesn't show anything,
anap.gettrial.Xepoch       = 'prestim';% Argument (Epoch) to xfrom in gettrial
anap.gettrial.Xepoch       = 'blank';  % Argument (Epoch) to xfrom in gettrial
anap.gettrial.RefChan      = 2;        % Reference channel (for DIFF)
anap.gettrial.sort         = 'trial';  % sorting with SIGSORT, can be 'none|stimulus|trial
anap.gettrial.Average      = 1;        % Concat/Average; It is also used from trial2obsp
anap.gettrial.trial2obsp   = 1;        % If set, it cat(1,..) the signals
anap.HemoDelay             = 2;
anap.HemoTail              = 2;


if ischar(varargin{1}) && strcmpi(varargin{1},'default'),
  % called like getanap('default'), return above values immediately.
  if strcmpi(varargin{1},'default'),  return;  end
end

if ischar(varargin{1}),
  % called like getanap(SESSION,...)
  SESSION = varargin{1};
else
  % "varargin{1}" must be a session structure.
  SESSION = varargin{1}.name;
end

SESSION = strrep(SESSION,'.','');  % to allow M02.lx1 style
% Matlab7 warns upper/lower case of 'SessionName',
% use which() function to suppers that messesage.
[tmp,SESSION] = fileparts(which(SESSION));
eval(SESSION);

% overwrite anap by ses.anap of the discription file.
if exist('ANAP','var') && ~isempty(ANAP),
  anap = subMergeStruct(anap,ANAP);
end
if nargin == 1,  return;  end


% overwrite anap by GRPP.anap of the description file
if exist('GRPP','var') && isfield(GRPP,'anap') && ~isempty(GRPP.anap),
  anap = subMergeStruct(anap,GRPP.anap);
end

% overwrite anap by GRP.xxx.anap of the discription file.
grp = {};
if ischar(varargin{2}),
  % called like getanap(Session,GrpName)
  grp = GRP.(varargin{2});
elseif isstruct(varargin{2}),
  % called like getnap(Session,grp)
  grp = GRP.(varargin{2}.name);
else
  % called like getanap(Session,ExpNo)
  % get GRP from ExpNo
  grpnames = fieldnames(GRP);
  for N = 1:length(grpnames),
    if any(GRP.(grpnames{N}).exps == varargin{2}),
      grp = GRP.(grpnames{N});
      break;
    end
  end
end

if isfield(grp,'anap') && ~isempty(grp.anap),
  anap = subMergeStruct(anap,grp.anap);
end


return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to merget structures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sctC = subMergeStruct(sctA, sctB)

sctC = sctA;
fnames = fieldnames(sctB);
for N = 1:length(fnames),
  tmpname = fnames{N};
  if isstruct(sctB.(tmpname)) && isfield(sctC,tmpname),
    sctC.(tmpname) = subMergeStruct(sctC.(tmpname),sctB.(tmpname));
  else
    sctC.(tmpname) = sctB.(tmpname);
  end
end

return;
