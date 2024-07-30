function oSes = gotox(SESSION)
%GOTOX - Read session file and go to the corresponding directory
%	oSes = gotox(SESSION) calls the corresponding description file and
%	goes to its home directory.
%	NKL, 10.10.00

if nargin < 1,
  cd(fileparts(fileparts(mfilename('fullpath'))));
  ls
  return;
end;

if isa(SESSION,'char'),
	Ses = getses(SESSION);
else
	Ses = SESSION;
end;

DIRS.matdir = 'x:/DataMatlab/';
Ses.sysp.matdir = DIRS.matdir;
cDir = fullfile(Ses.sysp.matdir,Ses.dirname);

cd(cDir);
if nargout,
	oSes = Ses;
end;

% assignin('base','Ses',Ses);
% ls

