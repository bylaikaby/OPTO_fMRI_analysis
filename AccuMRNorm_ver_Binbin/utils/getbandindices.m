function idx = getbandindices(arg, bandnames)
%GETBANDINDICES - Get band range and name information
% NKL 31.05.2008

if nargin < 2,
  bandnames = [];
end;

if isstruct(arg),
  BAND = arg.info.band;
elseif iscell(arg),
  BAND.arg{1}.info.band;
else
  anap = getanap(arg);
  BAND = anap.siggetblp.band;
end;

if isempty(bandnames),
  for N=1:length(BAND),
    bandnames{N} = BAND{N}{2};
  end;
end;

for N=1:length(BAND),
  curnames{N} = BAND{N}{2};
end;

idx = [];
for N=1:length(bandnames),
  tmpidx = find(strcmpi(bandnames{N},curnames));
  if ~isempty(tmpidx),
    idx(end+1) = tmpidx;
  end;
end;
