function C = sctmerge(A,B)
%SCTMERGE - replaces/adds fields of A with those of B.
%  C = SCTMERGE(A,B) replaces/adds fields of A with those of B.
%
%  VERSION :
%    0.90 03.08.05 YM  pre-release
%    0.91 20.12.05 YM  supports recursive calls.
%    0.92 08.05.07 YM  bug fix when A/B is empty
%
%  See also SCTCAT

if nargin < 2,  help sctmerge; return;  end

if isempty(A),  C = B;  return;  end
if isempty(B),  C = A;  return;  end

C = A;
fnames = fieldnames(B);
for N = 1:length(fnames),
  if ~isfield(C,fnames{N}),
    C.(fnames{N}) = B.(fnames{N});
  elseif isstruct(B.(fnames{N})),
    C.(fnames{N}) = sctmerge(C.(fnames{N}),B.(fnames{N}));
  else
    C.(fnames{N}) = B.(fnames{N});
  end
end

return;
