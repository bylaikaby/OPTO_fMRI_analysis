function [hp, lp] = infofilt(SESSION,GrpName)
%INFOFILT - Display cutoffs of highpass filters
% INFOFILT(SESSION, GrpName) displays filter cutoffs
%
% NKL, 13.04.07
  
if nargin < 2,
  help infofilt;
  return;
end;

Ses = goto(SESSION);

DOPLOT = 0;
if ~nargout,
  DOPLOT = 1;
end;
[hp,lp, dx] = subGetFilters(Ses,GrpName, DOPLOT);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hp, lp, dx] = subGetFilters(Ses,GrpName,DOPLOT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grp = getgrpbyname(Ses,GrpName);
mdl = expmkmodel(Ses,GrpName,'fhemo');
pv  = expgetpar(Ses,grp.exps(1));
pv  = pv.pvpar;
res = [pv.res pv.slithk];

if iscell(mdl),
  mdl = mdl{1};
end;
specmdl = subSpec(mdl);

fr=[0:size(specmdl.dat,1)-1]*specmdl.dx;
[mx,mi] = max(specmdl.dat);
tmpfr=fr(mi);
lp = (1/mdl.dx) * 0.40;
hp = tmpfr*0.75;
dx = mdl.dx;

if DOPLOT,
  subplot(2,1,1);
  t = gettimebase(mdl);
  plot(t,mdl.dat);
  drawstmlines(mdl);
  xlabel('Time in sec');
  ylabel('A.U.');
  grid on;
  title(sprintf('%s-%s: dx = %g sec, res = [%g %g %g] mm^3', mdl.session, mdl.grpname, mdl.dx, res));
  subplot(2,1,2);
  plot(fr, specmdl.dat);
  line([tmpfr tmpfr], get(gca,'ylim'),'color','r','linewidth',2);
  title(sprintf('Peak amplitude at %g Hz, Bandpass = [%g, %g]', tmpfr, hp, lp));
end;

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
len = 256;
fdat = fft(data,len,1);
specmdl.dx = Fs/len;
p = fdat.* conj(fdat) / len;
specmdl.dat = p(floor(1:(len/2)+1));
return;


