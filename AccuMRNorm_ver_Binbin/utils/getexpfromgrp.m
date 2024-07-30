function ExpNo = getexpfromgrp(SESSION, GrpName)
%GETEXPFROMGRP - Get name of group from experiment
%	ExpNo = GETEXPFROMGRP(SESSION, GrpName)
%	NKL, 15.10.02

Ses = goto(SESSION);
eval(sprintf('grp = Ses.grp.%s;',GrpName));
ExpNo = grp.exps(1);

