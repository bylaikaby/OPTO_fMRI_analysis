function EVT = dg_select(DG,OBSP,ETYPE,ESUBTYPE,varargin)
%DG_SELECT - Select events with given type/subtype.
%  EVT = DG_SELECT(DG,OBSP,ETYPE,ESUBTYPE,...) select events
%  with given type/subtype.
%  Supported options are 
%    'verbose' : 0|1, verbose or not.
%
%  NOTE :
%   * EVTTIMES are in msec.
%   * ETYPE can be a string or a number (0-255).
%   * DG structure has fields of 
%            e_pre: {33x1 cell}
%          e_names: [256x20 char]      <--- event names
%          e_types: {[6254x1 double]}  <--- event type (numbers, 0-255)
%       e_subtypes: {[6254x1 double]}  <--- event subtype
%          e_times: {[6254x1 double]}  <--- event timing in msec
%         e_params: {{6254x1 cell}}    <--- event parameters
%              ems: {{3x1 cell}}
%        spk_types: {[0x1 double]}
%     spk_channels: {[0x1 double]}
%        spk_times: {[0x1 double]}
%        obs_times: 0
%         filename: '\\Win49\E\DataNeuro\M02.lx1\m02lx1_001.dgz'
%
%  EXAMPLE :
%    dg = dg_read('\\Win49\E\DataNeuro\M02.lx1\m02lx1_001.dgz')
%    ev = dg_select(dg,1,'stimulus',2)
%    ev = 
%          name: 'Stimulus'
%          type: 27
%       subtype: 2
%          time: [38498 98198 396691]
%          pars: {[5x1 double]  [5x1 double]  [5x1 double]}
%
%  VERSION :
%    0.90 05.09.08 YM  pre-release
%
%  See also dg_read dg_evtcode

if nargin < 3,  eval(sprintf('help %s',mfilename)); return;  end

if nargin < 4,  ESUBTYPE = [];  end

VERBOSE = 1;
for N = 1:2:length(varargin),
  switch lower(varargin{N})
   case {'verbose'}
    VERBOSE = varargin{N+1};
  end
end


if ischar(ETYPE),
  ename = ETYPE;
  tmpname = deblank(cellstr(DG.e_names));
  etype = find(strcmpi(tmpname,ename)) - 1;
  if isempty(etype),
    % remove blanks, then try again...
    tmpname = strrep(tmpname,' ','');
    etype = find(strcmpi(tmpname,ename)) - 1;
    if VERBOSE && isempty(etype),
      %error(' ERROR %s: event ''%s'' not registered.\n',mfilename,ename);
      fprintf(' WARNING %s: event ''%s'' not registered.\n',mfilename,ename);
    end
  end
elseif isnumeric(ETYPE),
  if length(ETYPE) > 1,
    error(' ERROR %s: ETYPE must be a scalar .\n',mfilename);
  end
  etype = ETYPE;
else
  error(' ERROR %s: ETYPE must be a string or a scalar .\n',mfilename);
end

ename = '';
try
  ename = deblank(DG.e_names(etype+1,:));
end


if isempty(ESUBTYPE),
  idx = logical(DG.e_types{OBSP} == etype);
  if ~isempty(idx),
    ESUBTYPE = DG.e_subtypes{OBSP}(idx);
    ESUBTYPE = ESUBTYPE(:)';
  end
else
  idx = logical(DG.e_types{OBSP} == etype & DG.e_subtypes{OBSP} == ESUBTYPE);
end

et = DG.e_times{OBSP}(idx);
ep = DG.e_params{OBSP}(idx);

for N = 1:length(ep),
  if isnumeric(ep{N}),
    % fix bugs, some float value may have a small offset like
    % 1.2e-8 maybe,due to float->double conversion.
    ep{N} = round(ep{N}*10000.)/10000.;
  elseif ischar(ep{N}),
    % if chars, make them as a cell array.
    ep{N} = cellstr(ep{N});
  end
end


EVT.name    = ename;
EVT.type    = etype;
EVT.subtype = ESUBTYPE;
EVT.time    = et(:)';
EVT.pars    = ep(:)';
  

return
