function GRPS = validgrps(Ses)
%VALIDGRPS - Returns all valid groups defined in group sturctures
%	GRPS = VALIDGRPS(SESSION), gets valid groups from
%	Ses.grp.name(s). The function automatically excludes the group
%	having names: autoplot, test and misc. Such groups are analyzed
%	by specialized functions.
%   YM,  12.12.03  modified from validexps.

if ischar(Ses), Ses = goto(Ses);  end
SpecialGroups = {'autoplot';'test';'misc'};
if isfield(Ses,'SpecialGroups'),
  SpecialGroups = Ses.SpecialGroups;
end;

names = fieldnames(Ses.grp);
GRPS = {}; K = 1;
for N=1:length(names),
  SpecialStatus = 0;
  for S=1:length(SpecialGroups),
	if strcmp(SpecialGroups{S},names{N}),
	  SpecialStatus = 1;
	end;
  end;
  if ~SpecialStatus,
    GRPS{K} = names{N};  K = K + 1;
  end;
end;





