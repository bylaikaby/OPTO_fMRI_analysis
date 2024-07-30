function [odat NewFs]= myresample(dat,Fs,NewFs,tr)
%MYRESAMPLE - use matlab resample with a better filter and our
%mirroring procedure
if nargin<4,
  tr=NewFs*0.08; %transition width from passband to stopband
  USE_FIR=0;
else
  USE_FIR=1;
end;

passripple = 0.01;
dB         = 60;

newdx = 1/NewFs;
dx    = 1/Fs;
[p,q] = rat(dx/newdx,0.0001);
  
s = size(dat);
dat = reshape(dat,[s(1) prod(s(2:end))]);

if USE_FIR > 0,
  fsamp = p*Fs;  %note: freq of UPSAMPLED signal!
  fcuts = [NewFs/2-tr NewFs/2]; %we want cutoff to start transband before nyquist
  mags = [1 0];
  devs = [abs(1-10^(passripple/20)) 10^(-dB/20)];
  [n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fsamp);
  n = n + rem(n,2);
  b = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');
  
  
  pqmax = max(p,q);
  siglen = length(resample(double(dat(:,1)),p,q,b));
  
  mirror = ceil(length(b)/pqmax)*pqmax;
  idxmir = [mirror+1:-1:2 1:size(dat,1) size(dat,1)-1:-1:size(dat,1)-mirror-1];
  idxsel = [1:siglen] + round(mirror*p/q);
  datmir = resample(dat(idxmir,:),p,q,b);
  odat = datmir(idxsel,:);
  
  
else

  % DO NOT CHANGE THESE VALUES UNLESS U PASS THEM TO RESAMPLE
  % used to estimate mirror length
  % NOTE :
  % resample() will use firls with a Kaiser window as default.
  % followig code was taken from Matlab's resample() function.
  bta = 5;    N = 10;     pqmax = max(p,q);
  if( N>0 )
    fc = 1/2/pqmax;
    L = 2*N*pqmax + 1;
    h = p*firls( L-1, [0 2*fc 2*fc 1], [1 1 0 0]).*kaiser(L,bta)' ;
    % h = p*fir1( L-1, 2*fc, kaiser(L,bta)) ;
  else
    L = p;
    h = ones(1,p);
  end
  
  siglen = length(resample(double(dat(:,1)),p,q));
  
  mirror = ceil(length(h)/pqmax)*pqmax;
  idxmir = [mirror+1:-1:2 1:size(dat,1) size(dat,1)-1:-1:size(dat,1)-mirror-1];
  idxsel = [1:siglen] + round(mirror*p/q);
  datmir = resample(dat(idxmir,:),p,q);
  odat = datmir(idxsel,:);

end;

s(1)=size(odat,1);
odat = reshape(odat,s);

return;
