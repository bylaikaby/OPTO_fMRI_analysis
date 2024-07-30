function info = infoeleroi(SesName,GrpExp,varargin)
%INFOELEROI - Prints info of electrode-ROIs
%  INFOELEROI(SesName,GrpName,...)
%  INFOELEROI(SesName,ExpNo,...)  prints info of electrode-ROIs.
%
%  EXAMPLE :
%    >> infoeleroi('e10aw1')
%
%  VERSION :
%    0.90 31.07.2015 YM  pre-release
%
%  See also mroi mroi_load

if nargin == 0,  eval(['help ' mfilename]); return; end

Ses = getses(SesName);
if nargin < 2,  GrpExp = [];  end


if isempty(GrpExp),
  grps = getgroups(Ses);
else
  grp = getgrp(Ses,GrpExp);
  grps = { grp };
end

if ~nargout,
  for N = 1:length(grps),
    tmpgrp = getgrp(Ses,grps{N});
    if ~isimaging(Ses,tmpgrp),  continue;  end
    
    fprintf('%s %s: ',Ses.name, tmpgrp.name);
    ROI = mroi_load(Ses,tmpgrp);
    for K = 1:length(ROI.roi),
      tmproi = ROI.roi{K};
      if strncmpi(tmproi.name,'ele_',4),
        fprintf('\n  %s: slice=%d nvox=%d',tmproi.name,tmproi.slice,length(find(tmproi.mask(:)>0)));
      end
    end
    fprintf('\n');
  end
else
  J=1;
  for N = 1:length(grps),
    tmpgrp = getgrp(Ses,grps{N});
    if ~isimaging(Ses,tmpgrp),  continue;  end
    ROI = mroi_load(Ses,tmpgrp);
    for K = 1:length(ROI.roi),
      tmproi = ROI.roi{K};
      if strncmpi(tmproi.name,'ele_',4),
        info.name{J} = tmproi.name;
        info.slice{J} = tmproi.slice;
        J = J + 1;
      end
    end
  end
end;

return
