% PURPOSE : To communicate with the stim program.
% USAGE :   ret = netstimctrl(cmd,[arg1],...);
% ARGS :    cmd: 'send','timeout'
% NOTES :   'timeout' sets socket timeout.  Closing the socket before
%           completion of receiving data may cause unstable state
%           of the stim program.
% EXAMPLE : 
% send :   if failed, returns an empty string.
%             >>reply = netstimctrl('send','server','stimon')
%             >>reply = netstimctrl('send','server',4610,'stimon')
% timeout : in msec.  returns the old value of 'timeout'.
%           negative value means to use the blocking socket.
%             >>netstimctrl('timeout',-1)
%
% REQUIRE :"essnetapi.c" and "essnetapi.h"
% VERSION : 1.00  11-May-03  Yusuke MURAYAMA, MPI
