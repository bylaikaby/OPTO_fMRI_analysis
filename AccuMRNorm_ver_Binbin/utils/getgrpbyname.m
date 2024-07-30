function ogrp = getgrpbyname(Ses, GrpName)
%GETGRPBYNAME - Returns the group-structure of group GrpName
%	usage: ogrp = GETGRPBYNAME(SESSION, GrpName)
%	NKL, 15.10.02
%   YM,  21.12.05  use getgrp() since it accepts GrpName also.

ogrp = getgrp(Ses,GrpName);

%if ischar(Ses), Ses = goto(Ses);  end
%eval(sprintf('ogrp = Ses.grp.%s;',GrpName));
%ogrp.name = GrpName;

