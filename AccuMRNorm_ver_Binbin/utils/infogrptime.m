function timestr = infogrptime(SesName,GrpName)
%INFOGRPTIME - Get the  acquisition time of the group data from the ACQP structure
%
  
pv=expgetpar(SesName,GrpName);
tmpstr = pv.pvpar.acqp.ACQ_time;
tmpstr = strrep(tmpstr,'<','');tmpstr = strrep(tmpstr,'>','');
if ~nargout,
  fprintf('%s\n', tmpstr);
end;

