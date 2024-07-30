function [dat] = doFIRfilter(b,a,dat,USE_MIRROR)
%DOFILTER - Filter signal with defined parameters using fftfilt
%b: filter parameter
%a: filter parameter  
%dat: signals in columns
%USE_MIRROR: mirroring the signal  
  if ~exist('USE_MIRROR','var'),  USE_MIRROR = 1; end;

s = size(dat);
dat = reshape(dat,[s(1) prod(s(2:end))]);
  if USE_MIRROR > 0,
	fprintf('%s: FIR mirror\n',mfilename);
	mirror = max([length(b),length(a)]);
	idxmir = [mirror+1:-1:2 1:size(dat,1) size(dat,1)-1:-1:size(dat,1)-mirror-1];
	idxsel = [1:size(dat,1)] + mirror;
    datmir = s_filter(dat(idxmir,:),b);
    datmir = datmir(size(datmir,1):-1:1,:);
    datmir = s_filter(datmir,b);
    datmir = datmir(size(datmir,1):-1:1,:);
    dat = datmir(idxsel,:);
    
	clear datmir idxmir idxsel;
  else
	dat = s_filter(dat,b);
    dat = dat(size(dat,1):-1:1,:);
    dat = s_filter(dat,b);
    dat = dat(size(dat,1):-1:1,:);
  end;

dat = reshape(dat,s);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outdat=s_filter(sigdat,fdat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0,
  ns=size(sigdat,1);
  nchan=size(sigdat,2);
  nfft=2^nextpow2(ns);
  S_fft=fft(sigdat,nfft);
  clear sigdat;
  F_fft=fft(fdat,nfft);
  % Avoid memory overflow
  %SxF_fft=S_fft.*repmat(F_fft',1,size(sigdat,2));
  for chNo=1:nchan
	SxF_fft(:,chNo)=S_fft(:,chNo).*F_fft';
  end;
  outdat=ifft(SxF_fft,nfft);
  outdat=outdat(1:ns,:);
end;
% memory overflow, use for loop
for k=1:size(sigdat,2)
  outdat(:,k)=fftfilt(fdat',sigdat(:,k));
end;
%outdat=fftfilt(fdat',sigdat);
