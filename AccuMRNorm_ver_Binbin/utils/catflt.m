function oSig = catflt(Sig)
%CATFLT - band/low pass filtering of cat-structures
% oSig = CATFLT (Sig) band/low pass filtering of cat-structures
% NKL, 24.07.00

if (nargin < 1),
	error('usage: oSig = catflt(Sig);');
end

STOPPOLES = 6;
LOWCUTOF  = 1.75;
LOWPOLES  = 4;

% MAKE NOTCH FILTER TO GET RID OF RESPIRATION
rate = 1 / Sig.dx;
freq = hnanmean(Sig.fr,2);
amp  = hnanmean(Sig.spc,2);
l = 0.36;		% lowest respiration rate
r = 0.44;		% highestrespiration rate
idx = find(freq > l & freq < r);

[PEAK,PEAKIDX] = max(amp(idx));
PEAKIDX = PEAKIDX + idx(1);
PEAKFREQ = freq(PEAKIDX);
nyq = rate / 2;
nw	= [PEAKFREQ-0.03 PEAKFREQ+0.03]/nyq;
lowcutof = LOWCUTOF / nyq;

[b,a]	= butter(STOPPOLES,nw,'stop');
[b1,a1]	= butter(STOPPOLES,2*nw,'stop');
[lb,la] = butter(LOWPOLES,lowcutof,'low');

vars = {'aPts';'ePts';'tot';'lfp';'mua';'sdf'};

oSig = Sig;

for V=1:length(vars),
   eval(sprintf('sig = oSig.%s;',vars{V}));
   sig = detrend(sig);
   d1 = size(sig,1);
   d2 = size(sig,2);
   sig = sig(:);
   sig = filtfilt(b,a,sig);
   sig = filtfilt(b1,a1,sig);
   sig = filtfilt(lb,la,sig);
   sig = reshape(sig,[d1 d2]);
   eval(sprintf('oSig.%s = sig;',vars{V}));
end;








