function hdir = gethome(SESSION)
%GETHOME - Returns the full path of the session's home directory
%	hdir = GETHOME(SESSION)
%	NKL, 23.10.02

Ses = goto(SESSION);
hdir = strcat(Ses.sysp.matdir,Ses.dirname,'/');
