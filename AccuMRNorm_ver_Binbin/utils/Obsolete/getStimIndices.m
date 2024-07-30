function StimIndices = getStimIndices(Sig,ObjType,HemoDelay)
%GETSTIMINDICES - (Sig,ObjType,HemoDelay)
% PURPOSE : To get indices of the specified stimulus object for 'Sig.dat'.
% USAGE :   StimIndices = getStimIndices(Sig,'blank');
%           StimIndices = getStimIndices(Sig,'anystim',2);  % HemoDelay=2sec.
% NOTE :    'ObjType' can be 'blank', 'anystim' or stim types in STMFILE.
%           'HemoDelay' = 2 secs as default.
% SEEALSO : STMFILE
% VERSION : 0.90  21.10.03  YM
%         : 0.91  03.11.03  YM  supports 'prestm' assuming blank-stim...
%
% See also GETBASELINE

if nargin < 2,
  help getStimIndices;
  return;
end
if nargin < 3,
  if strcmpi(Sig.dir.dname,'tcImg'),
    HemoDelay = 2;
  else
    error('no HemoDelay');
  end
end

StimV     = Sig.stm.v{1};
StimT     = Sig.stm.t{1};
StimIndices = [];  StimTypes = {};
% reconstruct all stimobjs in the session.
for N = 1:length(StimT)-1,
  StimTypes{N} = Sig.stm.stmpars.StimTypes{StimV(N)+1};
end

switch ObjType
 case { 'nonblank','notblank','anystim','stim'}
  for N=1:length(StimTypes),
    if ~strcmpi(StimTypes{N},'blank'),
      % StimT(N),StimT(N+1)
      ts = round((StimT(N)   + HemoDelay)/Sig.dx);
      te = round((StimT(N+1) + HemoDelay)/Sig.dx)-1;
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  end
 case { 'prestim','prestm' }
  % assumes blank - stimulus ....
  ts = round((StimT(1)   + HemoDelay)/Sig.dx);
  te = round((StimT(1+1) + HemoDelay)/Sig.dx)-1;
  StimIndices = ts:te;
 otherwise
  for N=1:length(StimTypes),
    if strcmpi(StimTypes{N},ObjType),
      % StimT(N),StimT(N+1);
      ts = round((StimT(N)   + HemoDelay)/Sig.dx);
      te = round((StimT(N+1) + HemoDelay)/Sig.dx)-1;
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  end
end

if isempty(StimIndices),
  fprintf('getStimIndices: %s not found.',ObjType);
  StimIndices = [];
  return;
end

% select indices within data length.
if strcmpi(Sig.dir.dname,'tcImg'),
  % Sig.dat = (x,y,slice,t,...)
  dlen = size(Sig.dat,4);
else
  % Sig.dat = (time,chan,...)
  dlen = size(Sig.dat,1);
end
StimIndices = StimIndices(find(StimIndices > 0 & StimIndices <= dlen));

% make sure no overlapped regions
StimIndices = unique(StimIndices);


