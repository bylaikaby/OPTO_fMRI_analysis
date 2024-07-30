function EXPS = getexps(SESSION, GrpName)
%GETEXPS - Gets EXPS from group(s).
%  EXPS = GETEXPS(SESSION, GrpName) gets EXPS from group(s).
%
%  EXAMPLE :
%    >> exps = getexps(SESSION,{'movie1','movie2'})
%    >> exps = getexps(SESSION,'movie1')
%
%  VERSION :
%    0.90 25.12.03 YM  pre-release
%    0.91 30.01.12 YM  use mcsession/getexps
%
%  See also validexps mcsession/getexps


if nargin == 0,  help getexps;  return;  end
if nargin == 1,  GrpName = '';  end

Ses = getses(SESSION);

if isa(Ses,'mcsession'),
  EXPS = Ses.getexps(GrpName);
  return
end




% old structure style...
EXPS = [];
% get ExpNo
if isempty(GrpName),
  % GrpName is empty, get all EXPS.
  EXPS = validexps(Ses);
elseif iscell(GrpName) && ischar(GrpName{1}),
  % GrpName is given by group names.
  for N = 1:length(GrpName),
    eval(sprintf('EXPS = [EXPS, Ses.grp.%s.exps];',GrpName{N}));
  end
elseif ischar(GrpName),
  % GrpName is given by its name.
  eval(sprintf('EXPS = Ses.grp.%s.exps;',GrpName));
elseif isfield(GrpName,'exps'),
  % GrpName as a group structure
  EXPS = GrpName.exps;
else
  % GrpName is numric, ie. EXPS.
  % This ensures compatibility for 'project' files.
  EXPS = GrpName;
end;
