function [range, name, arg3idx, CutOff] = getbandinfo(arg1, arg2, arg3)
%GETBANDINFO - Get band range and name information
% EXAMPLES 
%           [range, name, blpidx] = getbandinfo(SesName, GrpName, 'gamma');
%           [range, name, blpidx] = getbandinfo(SesName, 'gamma');
%
% NKL 31.05.2008 (Updated 03.06.2013)

if nargin < 1,
  help getbandinfo;
  return;
end;

if nargin == 1,
  anap = getanap(arg1);
  band = anap.siggetblp.band;
  for N=1:length(band),
    range{N}=band{N}{2};
  end;
  return;
end;

if nargin < 3,
  arg3 = arg2;
end;

if ischar(arg1),
  % GETBANDINFO('e10aw1',...);
  SesName = arg1;
  Ses = goto(SesName);
  if nargin > 2,
    % GETBANDINFO('e10aw1','spont','mua')
    GrpName = arg2;
    anap = getanap(SesName, GrpName);
  else
    anap = getanap(SesName);
  end;
  band = anap.siggetblp.band;
  for N=1:length(band),
    tmprange{N} = band{N}{1};
    tmpcutoff(N) = band{N}{4};
  end;
  for N=1:length(band),
    tmpname{N} = band{N}{2};
    tmpcutoff(N) = band{N}{4};
  end;
  
else
  % GETBANDINFO(blp,...)
  blp = arg1;
  band = blp.info.band;
  % [1x2 double]    'gamma'    'LFP'    [0]
  for N=1:length(band),
    tmprange{N} = band{N}{1};
    tmpname{N} = sprintf('%s(%d-%d)[%d]', band{N}{2}, band{N}{1}, band{N}{4});
  end;
end;

if ischar(arg3),
  arg3 = {arg3};
end;

for J=1:length(arg3),
  for N=1:length(band),
    if strcmpi(lower(band{N}{2}),arg3{J}),
      range{J} = tmprange{N};
      name{J} = tmpname{N};
      arg3idx(J) = N;
      CutOff(J) = tmpcutoff(N);
      
      break;
    else
      range{J} = []; name{J} = []; arg3idx(J) = 0;
    end;
  end;
end;

if length(range)==1,
  range = range{1};
  name = name{1};
  arg3idx = arg3idx(1);
  CutOff = tmpcutoff(1);
end;




