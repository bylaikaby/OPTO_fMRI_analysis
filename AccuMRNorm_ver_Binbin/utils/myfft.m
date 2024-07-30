function fSig = myfft(Sig)
%MYFFT - FFT spectrum of Sig

s = size(Sig.dat);
if length(s) > 1,
  Sig.dat = reshape(Sig.dat,[s(1) prod(s(2:end))]);
end;
Fs = 1/Sig.dx;
Nyq = Fs/2;
fdx = Nyq/size(Sig.dat,1);
len = 2*size(Sig.dat,1);
fdat = fft(Sig.dat,len,1);
fdat = fdat(1:size(Sig.dat,1),:);
if length(s) > 1,
  fdat = reshape(fdat,s);
end;
fdat = abs(fdat);
fSig.dx = fdx;
fSig.dat = fdat;
if ~nargout,
  plot(fSig.dx*[0:length(fdat)-1], fSig.dat);
end;

return;

