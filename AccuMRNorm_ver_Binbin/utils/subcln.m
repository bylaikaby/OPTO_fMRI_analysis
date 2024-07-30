function Sig = subcln(Sig,TrialType)
%SUBCLN - Returns (squeezed) the Cln.dat(:,:,getflashtrials)
% SUBCLN calls getflashtrials and uses the returned indices to
% select a subset of trials for further processing.
% NKL 26.04.03

ix = getflashtrials(Sig);
Sig.dat = squeeze(Sig.dat(:,:,ix{TrialType}));


