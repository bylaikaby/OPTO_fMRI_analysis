% PURPOSE : To handle/receive ess-event from 'essmailer'.
%           Once the connection established, neteventlog receives
%           ess-event and its parameters via TCP/IP socket.
%           The internal buffer holds up to 128 events.
%           If it become full, the older event will be overwritten 
%           with the newer.
% USAGE :   ret = neteventlog(cmd,[arg1],...);
% ARGS :    cmd: 'login','logout','read'
% NOTES :   'login'/'logout' starts/stops network streaming of ess-event.
%           'read' retrieves a cell list of latest unread events.
% EXAMPLE : 
% login :   if failed, returns -1 otherwise >=0
%             >>sock = neteventlog('login','server')
%             >>sock = neteventlog('login','server',4622)
% read :    if no data available, returns empty cell array.
%           if connection closed, returns -1
%             >>events = neteventlog('read',sock)
% logout :    >>neteventlog('logout',sock)
%
% REQUIRE :"essnetapi.c" and "essnetapi.h"
% VERSION : 1.00  07-Aug-02  Yusuke MURAYAMA, MPI
