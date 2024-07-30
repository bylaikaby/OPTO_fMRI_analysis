function varargout = goto(SESSION,VERBOSE)
%GOTO - Read session file and go to the corresponding directory
%	oSes = goto(SESSION) calls the corresponding description file and
%	goes to its home directory.
%
%  VERSION :
%    1.00 10.10.00 NKL first release.
%    1.01 22.12.10 YM  use fullfile() instead of strcat().
%    2.01 30.01.12 YM  supports mcsession.
%
% See also GETSES

if nargin < 2,  VERBOSE = 0;  end;

DIRS = getdirs;
if nargin < 1,
  cd(DIRS.matdir);
  ls
  return;
end;

if strcmpi(SESSION,'physmri'),
  cd(fullfile(DIRS.matdir,'PhysMri'));
  return;
end;

if ischar(SESSION),
  Ses = getses(SESSION,VERBOSE);
else
  Ses = SESSION;
end;
if isempty(Ses),
  varargout{1} = {};
  return;
end;

if isa(Ses,'mcsession'),
  ddir = fullfile(Ses.dir('DataMatlab'),Ses.dir('dirname'));
else
  if isfield(Ses.sysp,'DataMatlab'),
    ddir = fullfile(Ses.sysp.DataMatlab,Ses.sysp.dirname);
  else
    ddir = fullfile(Ses.sysp.matdir,Ses.sysp.dirname);
  end
end

if ~exist(ddir,'dir')
  % try with fullpath...
  [status, msgstr] = mkdir(ddir);
  if ~status,
    % try again with separated path....
    [fp fr fe] = fileparts(ddir);
    [status, msgstr] = mkdir(fp,sprintf('%s%s',fr,fe));
  end
  if ~status,
    error('''%s'': mkdir error, %s',ddir,msgstr);
  end
end;

cd(ddir);
if nargout,  varargout{1} = Ses;  end;


% assignin('base','Ses',Ses);
% ls

