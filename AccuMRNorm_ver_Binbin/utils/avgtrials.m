function Sig = avgtrials(Sig)
%AVGTRIALS - Average Sig of all trials of a multi-trial observation period
% Sig = AVGTRIALS(Sig) checks if there are trials in the
% observation period and returns their average. The function should
% be only called if each trial is a simple repetition with the same
% stimulus parameters.
%
% NKL, 03.05.04
%
% See also GETSTIMINFO, GETTRIALINFO, GETSORTPARS, SIGSORT

if nargin < 1,  help avgtrials;  return;  end

DIM = length(size(Sig.dat)) + 1;
SortPar = getsortpars(Sig.session,Sig.ExpNo);
Sig = sigsort(Sig,SortPar.trial);
Sig.dat = hnanmean(Sig.dat,DIM);

if ~nargout * strcmp(Sig.dir.dname,'tcImg'),
  dspimg(Sig);
end;

return;
