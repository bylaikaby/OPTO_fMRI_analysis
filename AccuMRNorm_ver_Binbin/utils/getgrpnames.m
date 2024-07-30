function varargout = getgrpnames(Ses,arg2)
%GETGRPNAMES - Returns a cell-array of a session's group names
%   NAMES = GETGRPNAMES(SES) returns all group names.
%   NAMES = GETGRPNAMES(SES,EXPS) returns group names of EXPS.
%	NKL, 30.11.02
%	YM,  31.01.12 supports mcsession.
%
% See also GETGROUPS, GETGRP

if nargin == 0,  help getgrpnames;  return;  end

if nargin < 2,  arg2 = [];  end

EXPS = [];
ExpType = [];
if ischar(arg2),
  ExpType = arg2;
else
  EXPS = arg2;
end;

if ischar(Ses),  Ses = getses(Ses);  end

if isa(Ses,'mcsession'),
  names = Ses.grpname(EXPS);
  names = unique(names);
else
  % old structure style...
  if nargin == 1 | isempty(EXPS),
    names = fieldnames(Ses.grp);
    % NAMES = GETGRPNAMES(SES) 
  else
    % NAMES = GETGRPNAMES(SES,EXPS)
    for N = 1:length(EXPS),
      grp = getgrp(Ses,EXPS(N));
      names{N} = grp.name;
    end
    names = unique(names);
  end
end

if nargin > 1 & ~isempty(ExpType),
  tmp_name = {};
  for N=1:length(names),
    grp = getgrp(Ses, names{N});
    if find(strcmpi(grp.expinfo,ExpType)),
      tmp_name{end+1} = names{N};
    end;
  end;
  names = tmp_name;
end;

if ~nargout,
  txt = '';
  for N=1:length(names),
    if N==length(names),
      txt = strcat(txt,names{N});
    else
      txt = strcat(txt,names{N},',');
    end;
  end;
  fprintf('(%s)\n',txt);
else
  varargout{1} = names;
end;

    
