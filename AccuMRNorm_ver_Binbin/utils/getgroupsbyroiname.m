function ogrp = getgroupsbyroiname(Ses, RoiName)
%GETGROUPSBYROINAME - Returns the group-structure from RoiName
% ogrp = GETGROUPSBYROINAME (ses, roiname) - Returns the
% group-structure from RoiName. Since many groups will have the
% same ROI name, the function returns only the first one.
% NKL, 15.10.02

if ischar(Ses), Ses = goto(Ses);  end
grps = getgroups(Ses);
K=1;
ogrp = {};
for N=1:length(grps),
  if strcmp(grps{N}.grproi,RoiName),
	ogrp{K} = grps{N};
    K=K+1;
  end;
end;



