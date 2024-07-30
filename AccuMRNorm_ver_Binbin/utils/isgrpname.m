function answ = isgrpname(Ses, GrpName)
%ISGRPNAME - Returns 1 if GrpName is a group-name, otherwise 0
% names = ISGRPNAME (Ses,GrpName) searches Ses.grp to see whether
% the argument GrpName is indeed a group name.
% NKL, 30.11.02

if ischar(Ses),  Ses = goto(Ses);  end


answ = any(isgroup(Ses,GrpName));

return
