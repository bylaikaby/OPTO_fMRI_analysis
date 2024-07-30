function StimIndices = getStimIndices(Sig,ObjType,HemoDelay,HemoTail,varargin)
%GETSTIMINDICES - Gets time indices of specified object/period.
%   IND = GETSTIMINDICES(SIG,OBJTYPE) returns time indices of
%   OBJTYPE.  If SIG is tcImg/roiTs, HEMODELAY=2s and HEMOTAIL=5s as default.
%   IND = GETSTIMINDICES(SIG,OBJTYPE,HEMODELAY,HEMOTAIL) returns time
%   indices of OBJTYPE, taking into account of delay by HEMODELAY (sec)
%   and a tail of sigal as HEMOTAIL (sec).
%   IND includes all periods of OBJTYPE if OBJTYPE appears multiple times
%   in the stimulus sequence.
%
%   IND = GETSTIMINDICES(SIG,STIMID)
%   IND = GETSTIMINDICES(SIG,STIMID,HEMODELAY,HEMOTAIL) use the stimulus ID instead
%   of object's name.  STIMID can range from 0 to NumStimObjs-1.
%   See Sig.stm field for detail.
%
%   As OBJTYPE, GETSTIMINDICES accepts '-1','blank', 'anystim',
%   'prestim','poststim','all' and stimulus types in stm.stmtypes.
%   If OBJTYPE is 'prestim', the experiment is exptected to start
%   with a 'blank' period or describe stimulus IDs of 'prestim' as grp.prestim.
%   If OBJTYPE is '-1', a period before the first stimulus will be returned.
%   This '-1' may be useful when signal sorted by stimulus is given.
%
%  SEEALSO : STMFILE of each experiments
%  VERSION :
%    0.90  21.10.03  YM
%    0.91  03.11.03  YM  supports 'prestm' assuming blank-stim...
%    0.92  13.04.04  YM  use expgetpar().
%    0.93  07.07.04  YM  also accepts STIMID as the second argument.
%    0.94  13.07.04  YM  bug fix when numstim == 1.
%    0.95  21.07.04  YM  use "grp.prestim" for prestim period.
%    0.96  23.07.04  YM  supports HemoTail also.
%    0.97  17.01.05  YM  avoid error for D98.at1/at2.
%    0.98  10.03.05  YM  potential bug fix.
%    0.99  26.01.05  YM  check prestim.
%    1.00  06.03.06  YM  supports negative stimid (stm.v) of old session (d01nm4).
%    1.01  24.03.06  YM  supports Sig as a cell array
%    1.02  13.03.07  YM  supports 'awakeprestim'.
%    1.03  22.05.08  YM  supports 'poststim','all'.
%    1.04  10.07.13  YM  supports 'verbose' as options.
%
% See also GETBASELINE, EXPGETPAR, STM_READ, EXPGETSTM

if nargin < 2,  eval(sprintf('help %s;',mfilename)); return;  end
if nargin < 3,  HemoDelay = [];     end
if nargin < 4,  HemoTail  = [];     end

VERBOSE = 1;
for N = 1:2:length(varargin)
  switch lower(varargin{N})
   case {'verbose'}
    VERBOSE = any(varargin{N+1});
  end
end



[tmpv infosig] = issig(Sig);

if isempty(HemoDelay),
  % set default HemoDelay
  switch infosig.signame,
   case { 'tcImg','Pts','xcor','xcortc','roiTs','troiTs' }
    HemoDelay = 2;
   otherwise
    HemoDelay = 0;    
  end
end
if isempty(HemoTail),
  % set default HemoTail
  switch infosig.signame,
   case { 'tcImg','Pts','xcor','xcortc','roiTs','troiTs' }
    HemoTail = 5;
   otherwise
    HemoTail = 0;
  end
end

% call this function recursively, if Sig is a cell array.
if iscell(Sig),
  for N = 1:length(Sig),
    StimIndices{N} = getStimIndices(Sig{N},ObjType,HemoDelay,HemoTail);
  end
  return;
end


% NKL 02.06.04
% ATTENTION: Yusuke, this here has the following purpose: To
% estimate precisely what our Type I error is for
% Hypothesis-Testing, it is better to extract it from the data,
% instead of making assumptions. For example, we can estimate
% the probability of obtaining different r-values by chance, by
% using experiments without stimulus (e.g. baseline, spont, etc.)
% and correlate the responses with a stimulus pattern, that we
% chose from another experiment having visual stimulation. Our
% description files have the field "epoch" which was taken into
% account for the dependence analysis. We can also use it here
% for "simulating" visual stimulation. If epoch==3, the third
% experiment's stm is used etc...
% See also sigload.m
grp = getgrp(Sig.session,Sig.ExpNo(1));

if isfield(grp,'epoch') && grp.epoch,
  try
    ExpPar = expgetpar(Sig.session,grp.epoch);
  catch
    error(' %s: invalid ExpNo for grp.epoch. epoch=%d.\n',mfilename,grp.epoch);
  end
else
  if isfield(Sig,'stm'),
    ExpPar.stm = Sig.stm;
  else
    ExpPar = expgetpar(Sig.session,Sig.ExpNo(1));
  end
end;

if ~isfield(ExpPar,'stm') || isempty(ExpPar.stm),
  fprintf(' WARNING %s: empty .stm data. returning empty indices.\n',mfilename);
  StimIndices = [];
  return;
end


StimV       = ExpPar.stm.v{1};
StimT       = ExpPar.stm.time{1};
StimDT      = ExpPar.stm.dt{1};
StimIndices = [];  StimTypes = {};

% make sure to add end time for the last stimulus.
if length(StimV) == length(StimT),
  StimT(end+1) = ExpPar.stm.time{1}(end) + ExpPar.stm.dt{1}(end);
end

% reconstruct all stimobjs in the session.
for N = 1:length(StimT)-1,
  % supports negative IDs of old session like d01nm4.
  StimTypes{N} = ExpPar.stm.stmpars.StimTypes{abs(StimV(N))+1};
end


if ~isempty(strfind(ObjType,'stim[')) && ~isempty(strfind(ObjType,']')),
  SELSTIM = str2num(ObjType(strfind(ObjType,'['):end));
  ObjType = 'stimseq';
end

if isawake(grp) && isfield(grp,'daqver') && grp.daqver >= 2,
  if any(strcmpi(ObjType,{'prestim','prestm'})),
    ObjType = 'awakeprestim';
  end
  if any(strcmpi(ObjType,{'poststim','poststm'})),
    ObjType = 'awakepoststim';
  end
end

switch lower(ObjType),
 case { 'all' }
  StimIndices = 1:round(StimT(end)/Sig.dx(1));
 case { 'nonblank','notblank','anystim','stim','noblank'}
  % should take a period from T(N)+HemoDelay to T(N+1)+HemoTail
  for N=1:length(StimTypes),
    if ~strcmpi(StimTypes{N},'blank'),
      % StimT(N),StimT(N+1)
      ts = round((StimT(N)   + HemoDelay)/Sig.dx(1)) + 1;  % +1 for matlab indexing
      te = round((StimT(N+1) + HemoTail )/Sig.dx(1));
      if ts > te,
        fprintf(' ERROR %s: the period is shorter than HemoTail-HemoDelay.\n',mfilename);
        %keyboard
        continue;
      end
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  end
 case { 'prestim','prestm' }
  % should take a period from 0 to T(1)+HemoDelay
  if isfield(grp,'prestim') && ~isempty(grp.prestim),
    for N=1:length(grp.prestim),
      for K=1:length(StimV),
        if StimV(K) ~= grp.prestim(N), continue;  end
        ts = round((StimT(K)   + 0        )/Sig.dx(1)) + 1;  % +1 for matlab indexing
        te = round((StimT(K+1) + HemoDelay)/Sig.dx(1));
        tmpdur = ts:te;
        StimIndices = [StimIndices, tmpdur];
        break;
      end
    end
  else
    idx = find(~strcmpi(StimTypes,'blank') & ~strcmpi(StimTypes,'none') & ~strcmpi(StimTypes,'nostim'));
    if isempty(idx),
      % sesms to be always blank.
      %fprintf(' WARNING %s: no ''prestim'' period, returnig ''blank'' instead.\n',mfilename);
      StimIndices = getStimIndices(Sig,'blank',HemoDelay,HemoTail);
      % assumes blank - stimulus ....
      %ts = round((StimT(1)   + 0        )/Sig.dx(1)) + 1;  % +1 for matlab indexing
      %te = round((StimT(1+1) + HemoDelay)/Sig.dx(1));
    else
      % mixture of blank and stimulus
      idx = idx(1);
      if idx == 1,
        if StimT(idx) > Sig.dx(1),
          ts = 1;
          te = round((StimT(idx)   + HemoDelay)/Sig.dx(1));
          StimIndices = ts:te;
        else
          fprintf(' WARNING %s: no ''prestim'' period, returnig ''blank'' instead.\n',mfilename);
          StimIndices = getStimIndices(Sig,'blank',HemoDelay,HemoTail);
        end
      else
        ts = round((StimT(idx-1) + 0        )/Sig.dx(1)) + 1;  % +1 for matlab indexing
        te = round((StimT(idx)   + HemoDelay)/Sig.dx(1));
        StimIndices = ts:te;
      end
    end
  end

 case { 'poststim','poststm' }
  N = 2;
  while N <= length(StimTypes),
    % if N ~= blank, then skip
    if ~any(strcmpi(StimTypes{N},{'blank','none','nostim'})),
      N = N + 1;
      continue;
    end
    % if N-1 ~= blank, then process
    if ~any(strcmpi(StimTypes{N-1},{'blank','none','nostim'})),
      ts = round((StimT(N)   + HemoTail )/Sig.dx(1)) + 1;  % +1 for matlab indexing
      te = round((StimT(N+1) + HemoDelay)/Sig.dx(1));
      % if N+1 == blank, then include
      if N+1 <= length(StimTypes),
        while any(strcmpi(StimTypes{N+1},{'blank','none','nostim'})),
          te = round((StimT(N+1+1) + HemoDelay)/Sig.dx(1));
          N = N + 1;
        end
      end
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
      N = N + 1;
    end
  end

  
 case { 'blank','nostim'}
  for N=1:length(StimTypes),
    % should take a period from T(N)+HemoTail to T(N+1)+HemoDelay
    if strcmpi(StimTypes{N},'blank'),
      if N == 1 || strcmpi(StimTypes{N-1},'blank'),
        ts = round((StimT(N)   + 0       )/Sig.dx(1)) + 1;  % +1 for matlab indexing
      else
        ts = round((StimT(N)   + HemoTail)/Sig.dx(1)) + 1;  % +1 for matlab indexing
      end
      te = round((StimT(N+1) + HemoDelay)/Sig.dx(1));
      if ts > te,
        fprintf(' ERROR %s: the period is shorter than HemoTail-HemoDelay.\n',mfilename);
        keyboard
      end
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  end

 case {'stimseq'}
  SEQ_COUNT = 0;
  % should take a period from T(N)+HemoDelay to T(N+1)+HemoTail
  for N=1:length(StimTypes),
    if ~strcmpi(StimTypes{N},'blank'),
      SEQ_COUNT = SEQ_COUNT + 1;
      if ~any(SELSTIM == SEQ_COUNT),  continue;  end
      % StimT(N),StimT(N+1)
      ts = round((StimT(N)   + HemoDelay)/Sig.dx(1)) + 1;  % +1 for matlab indexing
      te = round((StimT(N+1) + HemoTail )/Sig.dx(1));
      if ts > te,
        fprintf(' ERROR %s: the period is shorter than HemoTail-HemoDelay.\n',mfilename);
        %keyboard
        continue;
      end
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  end
  
 case {'awakeprestim','prestimawake'}
  if ~exist('ExpPar','var') || isempty(ExpPar) || ~isfield(ExpPar,'evt'),
    ExpPar = expgetpar(Sig.session,Sig.ExpNo(1));
  end
  if isfield(ExpPar.evt,'systempar') && isfield(ExpPar.evt.systempar,'preStimTime'),
    PRE_T = ExpPar.evt.systempar.preStimTime / 1000 + 2;
  else
    PRE_T = 4;
  end
  if isfield(Sig,'sigsort'),
    for N = 1:length(StimV),
      ts = round((StimT(N) - PRE_T)/Sig.dx(1)) + 1;  % +1 for matlab indexing
      te = round((StimT(N) + HemoDelay)/Sig.dx(1));
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  else
    evtobs = ExpPar.evt.obs{1};
    evtobs.times.ttype(end+1) = evtobs.endE;
    for N = 1:length(evtobs.trialCorrect),
      if evtobs.trialCorrect(N) == 0,  continue;  end
      ts = evtobs.times.ttype(N) / 1000;
      te = evtobs.times.ttype(N+1) / 1000;
      tmpidx = find(StimT > ts & StimT < te);
      if isempty(tmpidx),  continue;  end
      ts = round((StimT(tmpidx(1)) - PRE_T)/Sig.dx(1)) + 1;  % +1 for matlab indexing
      te = round((StimT(tmpidx(1)))/Sig.dx(1));
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  end
  
 case { -1,'-1' }
  % take a period before the 1st stimulus.
  % should take a period from 0 to T(1)+HemoDelay
  ts = 0;
  te = round((StimT(1) + HemoDelay)/Sig.dx(1));
  StimIndices = ts:te;
  
 otherwise
  % should take a period from T(N)+HemoTail to T(N+1)+HemoDelay
  %%%%%%%%%%% ????? FIX THIS
  %fprintf('%s: Unknown epoch %s\n', mfilename,ObjType);
  %keyboard
  if isnumeric(ObjType),
    % ObjType is given by stimulus ID, not by name.
    ObjType = StimTypes{ObjType+1};
  end
  for N=1:length(StimTypes),
    if strcmpi(StimTypes{N},ObjType),
      % StimT(N),StimT(N+1);
      if N == 1 || strcmpi(StimTypes{N-1},'blank'),
        ts = round((StimT(N)   + HemoDelay)/Sig.dx(1)) + 1;  % +1 for matlab indexing
      else
        ts = round((StimT(N)   + HemoTail )/Sig.dx(1)) + 1;  % +1 for matlab indexing
      end
      if N < length(StimTypes) && strcmpi(StimTypes{N+1},'blank'),
        te = round((StimT(N+1) + HemoTail )/Sig.dx(1));
      else
        te = round((StimT(N+1) + HemoDelay)/Sig.dx(1));
      end
      if ts > te,
        fprintf(' ERROR %s: the period is shorter than HemoTail-HemoDelay.\n',mfilename);
        keyboard
      end
      tmpdur = ts:te;
      StimIndices = [StimIndices, tmpdur];
    end
  end
end

if isempty(StimIndices),
  if VERBOSE,
    fprintf('\n ERROR %s: ''%s'' not found.',mfilename,ObjType);
  end
  StimIndices = [];
  return;
end

% select indices within data length.
if isfield(Sig,'dir') && isfield(Sig.dir,'dname') && strcmpi(Sig.dir.dname,'tcImg'),
  % Sig.dat = (x,y,slice,t,...)
  dlen = size(Sig.dat,4);
else
  % Sig.dat = (time,chan,...)
  dlen = size(Sig.dat,1);
end
StimIndices = StimIndices(StimIndices > 0 & StimIndices <= dlen);

% make sure no overlapped regions
StimIndices = unique(StimIndices);


return
