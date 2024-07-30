function ogrp = getgrpbyroiname(Ses, RoiName)
%GETGRPBYROINAME - Returns the group-structure from RoiName
% ogrp = GETGRPBYROINAME (ses, roiname) - Returns the
% group-structure from RoiName. Since many groups will have the
% same ROI name, the function returns only the first one.
% NKL, 15.10.02

if ischar(Ses), Ses = goto(Ses);  end
grps = getgroups(Ses);
for N=1:length(grps),
  if strcmp(grps{N}.grproi,RoiName),
	ogrp = grps{N};
	return;
  end;
end;
ogrp = {};


