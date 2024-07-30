function idx = isgroup(SesName, GrpName)
%ISGROUP - Check if group GrpName is in session SesName
% function idx = isgroup(SesName, GrpName)

if nargin < 2,
  help isgroup;
  return;
end;

gnames = getgrpnames(SesName);

if ischar(GrpName),
  idx = find(strcmp(gnames,GrpName));
else
  idx = find(strcmp(gnames,GrpName.name));
end


return;
  