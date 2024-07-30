function stat = getbaseline(Sig, datname, epoch, ModelNo, HemoDelay, HemoTail)
%GETBASELINE - get baseline activity of signal "Sig"
%	stat = GETBASELINE(Sig) returns the mean, sd and epoch
%	indices of the baseline activity for the first dimension of the .dat
%	array of the prestimulus epoch, obtaining timing information from the
%	first stimulus model (datamame = .dat, ModelNo=1, epoch = 'prestim').
%
%	STAT = GETBASELINE(SIG, DATNAME);
%	STAT = GETBASELINE(SIG, DATNAME, EPOCH);
%	STAT = GETBASELINE(SIG, DATNAME, EPOCH, ModelNo);
%   STAT = GETBASELINE(SIG, DATNAME, EPOCH, ModelNo, HEMODELAY, HEMOTAIL);
%
%	The function will return the baseline for all Channels and
%	Observation Periods.
%
%	Typical examples of signals are:
%           Cln, tcImg, Lfp1Pow, blp, Pts/Nts etc.
%	Pemissible input arguments are:
%           dataname - "dat" or "pts", "nts" etc.
%           epoch - 'prestim' only initial prestimulus epoch
%           blank - if all epochs with no stimulation
%
%	ModelNo - 1:length(tcImg.stm{ObspNo}.stm)
%
%	NKL, 24.10.02
%   YM,  06.02.04  use getStimIndices() for experiments since 04.2003.
%   YM,  24.03.06  supports Sig as a cell array, 'allprestim' for the cell array.
%
% Determine DEFAULTS (dim=1,dataname='dat',ModelNo=1,epoch='prestim');
%
% See also TOSDU, XFORM, GETSTIMINDICES, HNANMEAN


OUTLIER_LIMIT_IN_SD = 5;
MINSD_ACCEPTABLE = 1.0e-020;

if nargin < 2,  datname = 'dat';    end;
if nargin < 3,  epoch = 'prestim';  end;
if nargin < 4,  ModelNo = 1;        end;
if nargin < 5,  HemoDelay = [];     end
if nargin < 6,  HemoTail  = [];     end

[tmpv infosig] = issig(Sig);

if isempty(HemoDelay),
  % set default HemoDelay
  switch infosig.signame,
   case { 'tcImg','Pts','xcor','xcortc','roiTs','troiTs' }
    HemoDelay = 2;
   otherwise
    HemoDelay = 0;
  end
end
if isempty(HemoTail),
  % set default HemoTail
  switch infosig.signame,
   case { 'tcImg','Pts','xcor','xcortc','roiTs','troiTs' }
    HemoTail = 5;
   otherwise
    HemoTail = 0;
  end
end


if ~strcmpi(datname,'dat'),
  Sig = sub_setdata(Sig,datname);
end;

DO_GLOBAL_STAT = 0;
% get data indices for 'epoch'
switch lower(epoch),
 case { 'allprestim', 'allprestm', 'allpre' },
  % if 'allprrestim' then compute global mean/std of 'prestim'
  % this may be usuful for troiTs/tblp to avoid misleading data interpretation,
  % due to pre-baselines difference.
  x = getStimIndices(Sig,'prestim',HemoDelay,HemoTail);
  if iscell(x),
    DO_GLOBAL_STAT = 1;
  end
 otherwise
  x = getStimIndices(Sig,epoch,HemoDelay,HemoTail);
end

stat = sub_getbaseline(Sig,x,infosig,OUTLIER_LIMIT_IN_SD,MINSD_ACCEPTABLE);

if DO_GLOBAL_STAT > 0,
  stat = sub_getglobal(stat);
end


if ~nargout,
  figure('Name',mfilename);
  sub_debugplot(Sig,stat);
end;


return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to compute baseline(s)
function stat = sub_getbaseline(Sig,x,infosig,OUTLIER_LIMIT_IN_SD,MINSD_ACCEPTABLE)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(Sig),
  % if Sig as a cell array, then call this function recursively.
  for N = 1:length(Sig),
    stat{N} = sub_getbaseline(Sig{N},x{N},infosig,OUTLIER_LIMIT_IN_SD,MINSD_ACCEPTABLE);
  end
  return;
end


% DIM_T=1: SigPow, Blp, Pts, Nts, AreaTc
% DIM_T=4: tcImg
DIM_T = 1;							% All arrays have time as dim=1
if strcmp(infosig.signame,'tcImg'),
  DIM_T = 4;							% Except tcImg and Xcor (dim=4)
end;


% if 'x' is empty, use a whole period.
if isempty(x),  x = 1:size(Sig.dat,DIM_T);  end


% All Neural signals have the "time" in Dim=1
% All Hemo signals (Exp or Group) have the "time" in Dim=4
dims = size(Sig.dat);
dims(DIM_T) = 1;
if DIM_T == 1,	% NEURAL SIGNAL
  stat.m = hnanmean(Sig.dat(x,:),DIM_T);
  stat.s = std(Sig.dat(x,:),1,DIM_T);
	
  %% GET RID OF OUTLIERS
  for K=1:size(Sig.dat,2),
    ix = find(Sig.dat(x,K)>(stat.m(K)+OUTLIER_LIMIT_IN_SD*stat.s(K)));
    Sig.dat(ix,K)=stat.m(K);
    stat.outliers(K)=length(ix);
  end;

  stat.m = reshape(stat.m,dims);
  stat.sinit = stat.s;
  stat.s = std(Sig.dat(x,:),1,DIM_T);
	
  % ============================================================
  % ATTENTION:
  % ============================================================
  % THIS IS KLUDGE INDEED, BUT FOR NOW IT'S FINE
  % IF THE SIGNAL IS 'FUNNY' IN THE PRESTIM PERIOD AND A ZERO STD
  % IS COMPUTED, THEN WE SCALE IT BY THE MEAN STD OF ALL OTHER
  % CHANNELS. THIS WILL MAKE THE SIGNAL A BIT 'STRONGER' BUT IT
  % HAPPENS VERY RARELY AND IT'S TOTALLY IRRELEVANT TO THE
  % 'SHAPE' OF THE TIME SERIES. LATER WE SHOULD FIND ANOTHER
  % SOLUTION!!!!
  % ============================================================
  if any(abs(stat.s)<MINSD_ACCEPTABLE),
    chix = find(abs(stat.s)<MINSD_ACCEPTABLE);
    fprintf('getbasline[WARNING]: channels ');
    fprintf('%d ', chix);
    fprintf('have SDs around zero\n');
    stat.s(chix)=nanmean(stat.s(:));
  end;
  stat.s = reshape(stat.s,dims);
else
  stat.m = hnanmean(Sig.dat(:,:,:,x,:),DIM_T);
  stat.m = reshape(stat.m,dims);
  stat.s = std(Sig.dat(:,:,:,x,:),1,DIM_T);
  stat.s = reshape(stat.s,dims);
end;

stat.ix = x(:);
stat.dx = Sig.dx(1);
stat.y  = stat.m + 5 * stat.s;
stat.dsp.func = 'dspgetbaseline';
stat.dsp.args = {};


return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to compute global baseline(s)
function stat = sub_getglobal(stat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmpstat = sub_addstat(stat,[]);

% DEBUG CODE
% dat = rand(30,2,3);
% tmpstat.ix = [1:30];
% tmpstat.n = [10 20];
% tmpstat.m{1} = squeeze(mean(dat(1:10,:,:),1));
% tmpstat.s{1} = squeeze(std(dat(1:10,:,:),[],1));
% tmpstat.m{2} = squeeze(mean(dat(11:30,:,:),1));
% tmpstat.s{2} = squeeze(std(dat(11:30,:,:),[],1));

try,
Nsum = sum(tmpstat.n);
m    = zeros(size(tmpstat.m{1}));
v    = zeros(size(tmpstat.s{1}));
for N = 1:length(tmpstat.n),
  tmpn  = tmpstat.n(N);
  tmpm  = tmpstat.m{N};
  tmps  = tmpstat.s{N};
  tmpv  = (tmpn-1) * tmps.^2 + tmpn * tmpm.^2;
  m = m + tmpm * tmpn / Nsum;
  v = v + tmpv / (Nsum -1);
end
v = v - Nsum / (Nsum-1) * m.^2;
catch,
  lasterr
  if ndims(m) ~= ndims(tmpm) | any(size(m) ~= size(tmpm)),
    fprintf('\n ERROR %s:\n  Dimension of Sig{X}.dat may differ from each other.',mfilename);
    fprintf('\n  Try to call like gebaseline(Sig{X},...).\n',mfilename);
  end
  error('ERROR at %s.sub_getglobal',mfilename);
end


newstat.ix = tmpstat.ix;
newstat.m  = m;
newstat.s  = sqrt(v);
newstat.y  = newstat.m + 5 * newstat.s;

clear tmpstat;

% DEBUG CODE
% squeeze(newstat.m)
% squeeze(mean(dat,1))
% squeeze(newstat.s)
% squeeze(std(dat,[],1))


stat = sub_copystat(stat,newstat);
  
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to compute global baseline(s)
function catstat = sub_addstat(stat,catstat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(catstat),
  catstat.ix = [];
  catstat.n  = [];
  catstat.m  = {};
  catstat.s  = {};
end

if iscell(stat),
  for N = 1:length(stat),
    catstat = sub_addstat(stat{N},catstat);
  end
  return;
end

catstat.ix = cat(1,catstat.ix,stat.ix);
catstat.n(end+1) = length(stat.ix);
catstat.m{end+1} = stat.m;
catstat.s{end+1} = stat.s;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION to copy global baseline(s)
function stat = sub_copystat(stat,newstat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(stat),
  for N = 1:length(stat),
    stat{N} = sub_copystat(stat{N},newstat);
  end
  return;
end

stat.ix = newstat.ix;
stat.m  = newstat.m;
stat.s  = newstat.s;
stat.y  = newstat.y;

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCITON to set .dat as data
function Sig = sub_setdata(Sig,datname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(Sig),
  for N = 1:length(Sig),
    Sig{N} = sub_setdata(Sig{N},datname);
  end
  return;
end

Sig.dat = Sig.(datname);

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCITON to set .dat as data
function sub_debugplot(Sig,stat,x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iscell(Sig),
  for N = 1:length(Sig),
    sub_debugplot(Sig{N},stat{N},x{N});
  end
  return;
end

tmp=mean(Sig.dat,3);
tmp=mean(tmp,2);
plot(tmp);
hold on;
m = mean(stat.m(:));
s = mean(stat.s(:));
line(get(gca,'xlim'),[m m],'color','w','linestyle','--');
line(get(gca,'xlim'),[m+s m+s],'color',[.5 .5 .5],'linestyle','--');

line([x(1) x(end)],[m m],'color','w','linestyle','--', ...
     'linewidth',3);
line([x(1) x(end)],[m+s m+s],'color',[.5 .5 .5],'linestyle','--', ...
	   'linewidth',3);
hold off;

return;

