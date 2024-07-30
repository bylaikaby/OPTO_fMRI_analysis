function [s,t] = mysin(Freq,Amp,Fs,Pnt)
%MYSIN - Get power spectrum of data dat and rate fs
% [s,t] = MYSIN(Freq,Amp,Fs,Pnt) is to quickly get the spectral power of
% dat. It returns only the amplitude and the frequencies.
% NKL, 04.04.04
  
if nargin < 4,
  Pnt = 80000;       % Sample so many points
end;

if nargin < 3,
  Fs = 250;         % 250Hz
  fprintf('Default N-Points %d, Sampling Rate: %dHz\n',Pnt,Fs);
end;

if nargin < 2,
  Amp = 1;          % Default amplitude 1
end;

if nargin < 1,
  Freq = 30;         % 4Hz
end;

dt = 1/Fs;
time = [0:Pnt-1] * dt;
time = time(:);
s = sin(2*pi*Freq*time);
s = s(:);

if nargout > 1,
  t = time;
end;

if ~nargout,
  T = 1/Freq;
  subplot(2,1,1);
  plot(time,s);
  set(gca,'xlim',[0 3*T]);
  xlabel('Time in seconds');
  subplot(2,1,2);
  myfft(s,Fs,'stem');
  xlabel('Frequency in Hz');
  set(gca,'xlim',[Freq-Freq/10 Freq+Freq/10]);
end;


