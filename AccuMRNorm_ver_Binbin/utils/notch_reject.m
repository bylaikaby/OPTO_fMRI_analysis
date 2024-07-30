function [x,corrfreq] = notch_reject(x,fband,Nf,Nwin)
%reject the most correlated frequency within the range fband using Nf
%possible frequency values in this range, signal is cut in Nwin windows
%frequency values are normalized (divided by sampling frequency)
%
%
%  EXAMPLE :
%    x = rand(10000,1);  % as (time,ch)
%    [x corrfreq] = notch_reject(x,[0.2 0.3], 10, 1)
%

if nargin < 3
  Nf = 1;
end
if nargin < 4
  Nwin = 10;
end
winind = SUB_equi_quant(1:size(x,1),Nwin);
% reject pure frequency from electrophysiology signal (e.g. line noise, avotec flickering)
% if ~iscell(x)
%     x={x};
% end
freqval = linspace(fband(1),fband(2),Nf);
for kwin = 1:max(winind)
  freqosc = exp(1i*2*pi*(1:sum(winind==kwin))'*freqval);
  normfreq(:,kwin) = dot(freqosc,freqosc);
  corrfreq(:,:,kwin) = freqosc'*x(winind==kwin,:);
end
[tmp,indmaxfreq] = max(mean(mean(abs(corrfreq),3),2));

for kwin=1:max(winind)
  freqosc = exp(1i*2*pi*(1:sum(winind==kwin))'*freqval(indmaxfreq));
  x(winind==kwin,:) = x(winind==kwin,:)-2*real(freqosc*corrfreq(indmaxfreq,:,kwin))/norm(freqosc).^2;

end

return




function xq = SUB_equi_quant(x,N)
%quantization in a vector space by equiprobable bining of the marginal distributions
%
%
% syntax	xq=equi_quant(x,N)
%
%  inputs
%
%	x - signal matrix (variable x samples)
%
%	N - number of bins
%
%
%  outputs
%
%	xq - binned signal, same dimension as input, integer values between 1 and N
%
%
% Author : Michel Besserve, MPI for Biological Cybernetics, Tuebingen, GERMANY

xq = NaN * x;
q = floor(size(x,2)/N);
r = size(x,2) - N*q;

nder = 0;
for k = 1:N
  if r > 0
    part((nder+1):(nder+q+1)) = k;
    r = r - 1;
    nder = nder + q + 1;
  else
    part((nder+1):(nder+q)) = k;
    nder = nder + q;
  end
end

for k_dim = 1:size(x,1)
  [tmp, ind] = sort(x(k_dim,:));
  xq(k_dim,ind) = part;
end

return
