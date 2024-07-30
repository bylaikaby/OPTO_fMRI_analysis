function grp = getgrp(Ses, GrpExp)
%GETGRP - Returns the group-structure by experiment number or group name.
%  usage: ogrp = GETGRP(SESSION, ExpNo/GrpName)
%
%  VERSION :
%    1.00 NKL 15.10.02
%    1.01 YM  22.04.04 accepts group name too.
%    1.02 YM  16.06.05 If ExpNo is a group structure, return as it is.
%    1.10 YM  15.04.13 clean up.
%
% See also getses

if nargin == 0,  help getgrp;  return;  end

if isa(GrpExp,'mcgroup'),  grp = GrpExp; return;  end

if ischar(Ses), Ses = getses(Ses);  end

if isa(Ses,'mcsession'),
  grp = Ses.getgrp(GrpExp);
  return
end
% old structure style
grp = [];
if ischar(GrpExp),
  GrpExp = deblank(GrpExp);
  % GrpExp as group's name, called like getgrp(Ses,GrpName)
  if ~any(strcmpi(fieldnames(Ses.grp),GrpExp)),
    gnames = fieldnames(Ses.grp);
    error('\nERROR %s: group-name ''%s'' not found in %s.m.\nEXISTING GROUPS for %s: %s',...
          mfilename,GrpExp,Ses.name,...
          Ses.name, sprintf('%s ',gnames{:}));
  end
  grp = Ses.grp.(GrpExp);
  grp.session = Ses.name;
  grp.name = GrpExp;
  
elseif isnumeric(GrpExp)
  % GrpExp as experiment's number, called like getgrp(Ses,ExpNo)
  gnames = fieldnames(Ses.grp);
  for N = 1:length(gnames),
    EXPS = Ses.grp.(gnames{N}).exps;
    if sum(ismember(GrpExp,EXPS))>0
      grp = Ses.grp.(gnames{N});
      grp.session = Ses.name;
      grp.name = gnames{N};
      break;
    end;
  end

elseif isstruct(GrpExp) && isfield(GrpExp,'exps') && isfield(GrpExp,'name') && any(strcmpi(fieldnames(Ses.grp),GrpExp.name)),
  % GrpExp as group structure, return as it is, called like getgrp(Ses,grp)
  grp = GrpExp;

elseif iscell(GrpExp),
  % GrpExp as a cell array of string, called like getgrp(Ses,{'grp1',...,'grpN'})
  for N = 1:length(GrpExp)
    grp{end+1} = getgrp(Ses,GrpExp{N});
  end

else
  fprintf('\n%s ERROR: invalid 2nd arg., must be ExpNo or GrpName.\n',mfilename);
end;

return;


