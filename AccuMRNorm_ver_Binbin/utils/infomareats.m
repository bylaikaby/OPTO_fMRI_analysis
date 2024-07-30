function [lowpass highpass] = infomareats(SESSION,ExpNo,RoiName)
%INFOMAREATS - Information to optimize temporal filtering
%
% BP = INFOMAREATS(SESSION, ExpNo, RoiName) displays models, spectra, and time information
% to optimize temporal filtering.
%
% Before calling the function:
%
%       1. Make sure that a ROI.MAT file exists, with at least the V1 ROI defined
%       2. Set GRP.name.anap.gettrial.status = 0;
%       3. Define XCOR model: GRPP.corana{1}.mdlsct = {'hemo'};
%       4. Check time courses for artifact
%       5. Check the low-high bandpass values
%       6. Set the values (in the title) to 
%       7. Apply the values and check their effects on time course
%
% NKL, 02.10.06
  
if nargin < 2,
  help infomareats;
  return;
end;

if nargin < 3,
  RoiName = {'V1'};
end;

Ses = goto(SESSION);
if ~isnumeric(ExpNo),
  grp = getgrpbyname(Ses,ExpNo);
  ExpNo = grp.exps(1);
end;
grp = getgrp(Ses,ExpNo);
GrpName = grp.name;
mdl = expmkmodel(Ses,ExpNo);
fmdl = subSpec(mdl);
fr=[0:size(fmdl.dat,1)-1]*fmdl.dx;

[mx,mi] = max(fmdl.dat);
ll = fr(mi)*0.50;
hl = fr(end)*0.85;

if nargout,
  lowpass = ll;
  highpass = hl;
  return;
end;
txt = sprintf('%s-%s, Bandpass: [%3.4f %3.4f], DX=%3.3f sec (%3.3f Hz)',...
              Ses.name,GrpName,ll,hl,mdl.dx,1/mdl.dx);

anap = getanap(Ses,grp);
if anap.gettrial.status,
  fprintf('INFOMAREATS: To run this function "anap.gettrial.status" must be zero!\n');
  fprintf('INFOMAREATS: Edit the group variable in the description file and rerun\n');
  return;
end;

roiTs = subMareats(SESSION,ExpNo,RoiName);
if isempty(roiTs),
  fprintf('INFOMAREATS: No ROI found\n');
  return;
end;

roiTs = subCorAna(Ses,ExpNo,grp,roiTs);

VERBOSE=0;
COL='rgbmykc';
rThr = -0.15;
K=1;
for N=1:length(RoiName),
  roiTs{N} = mroitsget(roiTs{N},[],RoiName{N});         % Get desired ROI
  roiTs{N} = mroitssel(roiTs{N},rThr);                  % Get TS meeting stat-criteria
  roiTs{N} = roiTs{N}{1};                               % No multiple ROIs in this function
  for M=1:length(roiTs{N}.dat),
    roiTs{N}.dat{M} = detrend(hnanmean(roiTs{N}.dat{M},2));
    if VERBOSE,
      t = [0:size(roiTs{N}.dat{M},1)-1] * roiTs{N}.dx; t = t(:);
      plot(t,roiTs{N}.dat{M},COL(K));
      K=K+1;
      hold on;
    end;
  end;
end;

t = [0:size(roiTs{1}.dat{1},1)-1] * roiTs{1}.dx; t = t(:);
K=1;
for N=1:length(RoiName),
  for M=1:length(roiTs{N}.dat),
    dat(:,K) = roiTs{N}.dat{M};
    K=K+1;
  end;
end;
roiTs = roiTs{1};
roiTs.dat = dat;

specs = subSpec(roiTs);

fr=[0:size(specs.dat,1)-1]*specs.dx;
nyq = (1/roiTs.dx)/2;
[b,a] = butter(4,[ll hl]/nyq,'bandpass');
dlen   = size(roiTs.dat,1);
flen   = max([length(b),length(a)]);

idxfil = [flen+1:-1:2 1:dlen dlen-1:-1:dlen-flen-1];
idxsel = [1:dlen] + flen;
tmp = roiTs.dat(idxfil);
tmp = filtfilt(b,a,tmp);
froiTs.dat = tmp(idxsel);
froiTs.dx = roiTs.dx;


mfigure([100 100 800 1000]);
subplot(2,1,1);
t = [0:size(roiTs.dat,1)-1] * roiTs.dx;
thd(1) = plot(t, froiTs.dat,'color','c','linewidth',3);
hold on;
thd(2) = plot(t, roiTs.dat,'color','k');
legend(thd,'Filtered','Raw','Location','north');

subplot(2,1,2);
fspecs = subSpec(froiTs);
hd(1)=plot(fr, fspecs.dat,'color','c','linewidth',3);
hold on;
hd(2)=plot(fr, specs.dat,'color','k');

fmdl.dat = max(specs.dat)*fmdl.dat/max(fmdl.dat);
hd(3)=plot(fr,fmdl.dat,'g','linewidth',2,'linestyle',':');

line([ll ll],get(gca,'ylim'), 'color','r','linewidth',2);
line([hl hl],get(gca,'ylim'), 'color','r','linewidth',2);

legend(hd,'Filtered','Raw','Stim-based','Location','north');
title(txt);
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function roiTs = subMareats(SESSION,ExpNo,RoiName)
% Extract time series w/ no preprocessing at all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ses = goto(SESSION);                    % Read session info
grp = getgrp(Ses,ExpNo);
anap = getanap(Ses,grp);
if ~exist('Roi.mat','file'),
  fprintf('INFOMAREATS: Requires that ROIs are defined\n');
  fprintf('INFOMAREATS: Run MROI(%s), and then call this function\n',Ses.name);
  roiTs = {};
  return;
end;
fprintf('INFOMAREATS: ROI %s is used for spectra analysis!\n');
if ischar(RoiName),
  RoiName = {RoiName};
end;

fprintf('loading.');
Roi = matsigload('roi.mat',grp.grproi);
tcImg = sigload(Ses,ExpNo,'tcImg');

rts.session   = Roi.session;
rts.grpname   = tcImg.grpname;
rts.ExpNo     = tcImg.ExpNo;
rts.dir       = Roi.dir;
rts.dir.dname = 'roiTs';
rts.dsp       = Roi.dsp;
rts.dsp.func  = 'dsproits';
rts.grp       = tcImg.grp;
rts.evt       = tcImg.evt;
rts.stm       = tcImg.stm;
rts.ele       = Roi.ele;
rts.ds        = tcImg.ds;
rts.dx        = tcImg.dx;
rts.ana       = mean(tcImg.dat,4);

ValidRoiNo = 1;
for RoiNo=1:length(RoiName),
  tmp = mtimeseries(tcImg,Roi,RoiName{RoiNo});
  if isempty(tmp), continue; end;
  roiTs{ValidRoiNo}           = rts;
  roiTs{ValidRoiNo}.name      = tmp.name;
  roiTs{ValidRoiNo}.slice     = -1;                 % All slices concat-ed
  roiTs{ValidRoiNo}.coords    = tmp.coords;
  roiTs{ValidRoiNo}.roiSlices = tmp.roiSlices;
  roiTs{ValidRoiNo}.dat       = tmp.dat;
  ValidRoiNo = ValidRoiNo + 1;
end;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNTION to run correlation analysis for 'roiTs'
function roiTs = subCorAna(Ses,ExpNo,grp,roiTs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neumdl = [];
for M=1:length(grp.corana)
  fprintf('%s.',grp.corana{M}.mdlsct);
  mdlsct{M} = expmkmodel(Ses,ExpNo,grp.corana{M}.mdlsct);
  neumdl(M) = ~any(strcmpi({'hemo','boxcar','fhemo','ir'},grp.corana{M}.mdlsct));
end;

if isstim(Ses,grp.name) | any(neumdl),
    fprintf(' matscor...');
    roiTs = matscor(roiTs,mdlsct);
else
  fprintf(' cleaning ./.p...');
  for R = 1:length(roiTs),
    roiTs{R}.r = {};  roiTs{R}.p = {};
    roiTs{R}.r{1} = zeros(size(roiTs{R}.dat,2),1);
    roiTs{R}.p{1} = ones(size(roiTs{R}.dat,2),1);
  end
end
fprintf(' done.\n');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function specmdl = subSpec(Sig)
% It is difficult to identify the frequency components by looking at the original signal. ...
% Converting to the frequency domain, the discrete Fourier transform of the noisy signal y ...
% is found by taking the 512-point fast Fourier transform (FFT): 
% Y = fft(y,512);
%
% The power spectrum, a measurement of the power at various frequencies, is 
% Pyy = Y.* conj(Y) / 512;
%
% Graph the first 257 points (the other 255 points are redundant) on a meaningful frequency axis: 
% f = 1000*(0:256)/512;
% plot(f,Pyy(1:257))
% title('Frequency content of y')
% xlabel('frequency (Hz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
specmdl = Sig;
data = detrend(Sig.dat);
Fs = 1/Sig.dx;
Nyq = Fs/2;
len = size(Sig.dat,1);
len = getpow2(len,'ceiling');
if len < 512,
  len = 512;
end;
fdat = fft(data,len,1);
specmdl.dx = Fs/len;
p = fdat.* conj(fdat) / len;
specmdl.dat = p(floor(1:(len/2)+1));
return;

