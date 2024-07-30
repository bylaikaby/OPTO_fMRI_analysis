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
%
% Determine DEFAULTS (dim=1,dataname='dat',ModelNo=1,epoch='prestim');
%
% See also TOSDU, XFORM, GETSTIMINDICES, HNANMEAN


OUTLIER_LIMIT_IN_SD = 5;
MINSD_ACCEPTABLE = 1.0e-020;

if nargin < 2,  datname = 'dat';    end;
if nargin < 3,  epoch = 'prestim';  end;
if nargin < 4,  ModelNo = 1;        end;
if nargin < 5,
  % Check data type to detemine if hemodynamic delay is necessary
  switch Sig.dir.dname
   case {'tcImg','Pts','xcor','xcortc','roiTs','troiTs'}
    HemoDelay = 2;		% 2 secs hemodynamic delay...
   otherwise
    HemoDelay = 0;
  end;
end
if nargin < 6,
  % Check data type to detemine if hemodynamic tail is necessary
  switch Sig.dir.dname
   case {'tcImg','Pts','xcor','xcortc','roiTs','troiTs'}
    HemoTail  = 5;		% 5 secs hemodynamic tail...
   otherwise
    HemoTail  = 0;
  end;
end


% DIM=1: SigPow, Blp, Pts, Nts, AreaTc
% DIM=4: tcImg
DIM = 1;							% All arrays have time as dim=1
if strcmp(Sig.dir.dname,'tcImg'),
  DIM = 4;							% Except tcImg and Xcor (dim=4)
end;

if ~strcmp(datname,'dat'),
  eval(sprintf('Sig.dat = Sig.%s;', datname));
end;


x = getStimIndices(Sig,epoch,HemoDelay,HemoTail);
% if 'x' is empty, use a whole period.
if isempty(x),  x = 1:size(Sig.dat,DIM);  end


% All Neural signals have the "time" in Dim=1
% All Hemo signals (Exp or Group) have the "time" in Dim=4
dims = size(Sig.dat);
dims(DIM) = 1;
if DIM == 1,	% NEURAL SIGNAL
  stat.m = hnanmean(Sig.dat(x,:),DIM);
  stat.s = std(Sig.dat(x,:),1,DIM);
	
  %% GET RID OF OUTLIERS
  for K=1:size(Sig.dat,2),
    ix = find(Sig.dat(x,K)>(stat.m(K)+OUTLIER_LIMIT_IN_SD*stat.s(K)));
    Sig.dat(ix,K)=stat.m(K);
    stat.outliers(K)=length(ix);
  end;

  stat.m = reshape(stat.m,dims);
  stat.sinit = stat.s;
  stat.s = std(Sig.dat(x,:),1,DIM);
	
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
  stat.m = hnanmean(Sig.dat(:,:,:,x,:),DIM);
  stat.m = reshape(stat.m,dims);
  stat.s = std(Sig.dat(:,:,:,x,:),1,DIM);
  stat.s = reshape(stat.s,dims);
end;

stat.ix = x(:);
stat.dx = Sig.dx(1);
stat.y  = stat.m + 5 * stat.s;
stat.dsp.func = 'dspgetbaseline';
stat.dsp.args = {};

if ~nargout,
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
end;

