function txt = infogrp(SES,GrpName)
%INFOGRP - Show all groups with their basic parameters
% INFOGRP(SES) - run this function and paste the displayed text into the description
% file under the heading "GROUPS".
%
% NKL 02.02.2009

if iscell(SES),
  SES = rpsessions(SES{:});
else
  SES = {SES};
end;

if nargin < 2,
  GrpName = [];
end;

for S=1:length(SES),
  SesName = SES{S};
  Ses = goto(SesName);
  grpnames = getgrpnames(SesName);
  if ~isempty(GrpName),
    idx = find(strcmp(GrpName,grpnames));
    grpnames = grpnames(idx);
  end;
  oGrp{S} = grpnames;
end;

if ~nargout,
  try,
    for S=1:length(SES),
      groupNames = '';
      for N=1:length(oGrp{S}),
        groupNames = strcat(groupNames,sprintf('%s.', oGrp{S}{N}));
      end;
      if nargin>1,
        grp = getgrp(SES{S}, GrpName);
        expinfo = sprintf('%s ', grp.expinfo{:});
        fprintf('%s %s %s\n', upper(SES{S}), groupNames, expinfo);
      else
        fprintf('%s %s\n', upper(SES{S}), groupNames);
      end;
    end;
  catch,
    disp(lasterr);
    keyboard;
  end;
end;
return;
