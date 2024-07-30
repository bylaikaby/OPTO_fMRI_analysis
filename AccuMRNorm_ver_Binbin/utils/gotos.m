function varargout = gotos(SESSION,VERBOSE)
%GOTOS - Read session file and go to the corresponding directory
%	oSes = gotos(SESSION) calls the corresponding description file and
%	goes to its home directory.
%	NKL, 10.10.00
%
% See also goto gotox getses

if nargin < 2,  VERBOSE = 0;  end;

if nargin < 1,
  cd(getdirs('DataMatlab'));
  ls
  return;
end;


Ses = goto(SESSION);

if ~exist('SIGS','dir')
  [status, msgstr] = mkdir('SIGS');
  if ~status,
    error('''%s'': mkdir error, %s','SIGS',msgstr);
  end
end;
cd('SIGS');

if nargout,  varargout{1} = Ses;  end;


% assignin('base','Ses',Ses);
% ls

