function EXPS = validexps(SESSION,IncludeSpecialGroups)
%VALIDEXPS - Returns all valid experiments defined in group sturctures
%	EXPS = VALIDEXPS(SESSION), gets valid experiments from
%	Ses.grp.name(s). The function automatically excludes the group
%	having names: autoplot, test and misc. Such groups are analyzed
%	by specialized functions.
%	NKL, 29.09.01

if ischar(SESSION)
  Ses = getses(SESSION);
else
  Ses = SESSION;
end
SpecialGroups = {'autoplot';'test';'misc'};

if nargin < 2,
  IncludeSpecialGroups = 0;
end
if ischar(IncludeSpecialGroups),
  if any(strcmpi(IncludeSpecialGroups,{'all','include','IncludeSpecialGroups'})),
    IncludeSpecialGroups = 1;
  else
    IncludeSpecialGroups = 0;
  end
end


names = getgrpnames(Ses);
EXPS = [];
for N=1:length(names),
  if ~IncludeSpecialGroups && any(strcmpi(names{N},SpecialGroups)),
    SpecialStatus = 1;
  else
    SpecialStatus = 0;
  end
  if ~SpecialStatus,
    exps = getexps(Ses,names{N});
	EXPS = cat(2,EXPS,exps);
  end;
end;
EXPS = unique(EXPS);





