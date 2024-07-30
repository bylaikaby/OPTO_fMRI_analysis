function oSig = condcat(Sig,Cond)
%CONDCAT - Merge different experimental conditions along NoObsp dim
% CONDCAT(Sig,Cond) Concatanate different conditions in a multidimensional
% cell array.
% NKL 22.05.03

if nargin < 2,
  error('usage: condcat(Sig,Cond);');
end;

if length(Cond) == 1,
  oSig = Sig{Cond};
  return;
end;

DIM = length(size(Sig{1}.dat));
oSig = Sig{Cond(1)};
for N=2:length(Cond),
  oSig.dat = cat(DIM,oSig.dat,Sig{Cond(N)}.dat);
end;

  
