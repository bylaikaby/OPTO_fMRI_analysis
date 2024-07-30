% PURPOSE : To handle/receive streamed data from winstreamer.
%           Once the connection established, netstreamer receives
%           digitized data arround observation via TCP/IP socket.
%           The size of internal buffer is ~4M bytes and, if it's
%           full, the older data will be overwritten with the newer.
% USAGE :   [ret,[endtime,sampt]] = netstreamer(cmd,[arg1],...);
% ARGS :    cmd: 'login','logout','read'
% NOTES :   'login'/'logout' starts/stops network streaming.
%           'read' retrieves latest unread data. 
%           Retrieved waveform is aligned by (chan,t) and the last
%           channesl represents the trigger signal.
%           endtime is a timestamp since latest beginObs.
%           Both endtime and sampt are in msec.
% EXAMPLE : 
% login :   if failed, returns -1 otherwise >=0
%             >>sock = netstreamer('login','server')
%             >>sock = netstreamer('login','server',4612)
% read :    if no data available, returns empty data.
%           if connection closed, returns -1
%             >>wave = netstreamer('read',sock)
%             >>[wave,endtime,sampt] = netstreamer('read',sock)
% logout :    >>netstreamer('logout',sock)
%
% REQUIRE :"essnetapi.c" and "essnetapi.h"
% SEEALSO : removeTriggerData.m
% VERSION : 1.00  07-Aug-02  Yusuke MURAYAMA, MPI
