function [b,a,pars] = designFIRFilter(lim,Fs,mode,tr,stopdB,passripple)
%DESIGNFIRFILTER - designs a finite impulse response filter (kaiser window)
%lim:      desired bandwidth of resultant signal
%Fs:       sampling rate of input signal
%mode:     {'lowpass','highpass','bandpass'}
%tr:       transition bandwidth in Hz
%stopdB:   stopband attenuation in dB
%passripple:  ripple in passband in dB
%EXAMPLE   [b,a,pars] = designFIRflt(1,500,'high',1,60,0.01);  
% - design highpass of 1Hz of signal with 500Hz sampling rate with
% 1Hz transition bandwidth 60dB attenuation in stopband and 0.01 dB passripple  
%SEE ALSO doFIRFilter
  
if nargin<3, 
  fprintf('%s: please provide at least lim, Fs, mode parameters\n',mfilename);
  return;
end;
  
if lim(1) == 0, 
  mode='lowpass';
end
if length(lim)==2 && (lim(2) > (Fs/2))
  mode='highpass';
  lim(2)=Fs/2;
end;
if ~exist('tr','var') || isempty(tr), tr=1; end;
if ~exist('stopdB','var') || isempty(stopdB), stopdB=60; end;
if ~exist('passripple','var') || isempty(passripple), passripple=0.01; end;

fprintf('%s: designing %s filter Fs:%.1f tr:%.1f stopdB:%d passripple:%.2f\n',...
        mfilename,mode,Fs,tr,stopdB,passripple);

switch lower(mode),
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%
 case {'lowpass','lp','low'}
  if length(lim)==1,
    fcuts = [lim (lim+tr)];
  elseif lim(1)==0,
    fcuts = [lim(2) (lim(2)+tr)];
  else
    fprintf('%s: wrong bandwidth for lowpass\n',mfilename);
    return;
  end;
  mags = [1 0];
  devs = [abs(1-10^(passripple/20)) 10^(-stopdB/20)];
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case {'highpass','hp','high'}
  if (lim(1)-tr)<0,
    fprintf('%s: WARNING: transition goes below zero -> narrowed down\n',mfilename);
	tr=lim(1);
  end;
  fcuts = [(lim(1)-tr) lim(1)];
  mags = [0 1];
  devs = [10^(-stopdB/20) abs(1-10^(passripple/20))];

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 case {'bandpass','bp','band'}
  if (lim(1)-tr)<0,
    fprintf('%s: WARNING: transition goes below zero -> narrowed down\n',mfilename);
	tr=lim(1);
  end;
  fcuts = [(lim(1)-tr) lim(1) lim(2) (lim(2)+tr)];
  mags = [0 1 0];
  devs = [10^(-stopdB/20)  abs(1-10^(passripple/20)) 10^(-stopdB/20)];
end
[n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,Fs);
n = n + rem(n,2);
b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
a = 1;

pars.fname      = 'fir1-kaiser';
%ftype = ..., % given by above kaiserord().
pars.forder     = n;
pars.tr         = tr;
pars.stopdB     = stopdB;
pars.passripple = passripple;

return
