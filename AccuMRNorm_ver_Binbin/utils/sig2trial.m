function oSig = sig2trial(Sig,Ses,ExpNo)
%SIG2TRIAL - Resort signal to individual trials
% oSig = SIG2TRIAL (Sig,Ses,ExpNo) splits observation periods into stimulus
% or trial-based epochs.
% NKL 01.04.04

if nargin < 2,
  Ses = getses(Sig.session);
  ExpNo = Sig.ExpNo;
end;

sortpar = getsortpars(Ses,ExpNo);
oSig = sigsort(Sig,sortpar.trial);


