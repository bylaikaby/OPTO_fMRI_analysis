function varargout = whofile(varargin)
%WHOFILE - List file variables by calling who(filename,'-file',...)
% WHOFILE lists variables in the corresponding matlab file.
%
%   S = WHOFILE(SES,EXPNO/GRPNAME)
%   S = WHOFILE(SES,EXPNO/GRPNAME,VAR1,VAR2,...)
%   In those cases, CATFILENAME() or GRPNAME will be used to get the
%   filename.
%
%   S = WHOFILE(FILENAME)
%   S = WHOFILE(FILENAME,VAR1,VAR2,...) performs WHO('-file',FILENAME,...).
%   FILENAME must have .mat extension.
%
%   If no VAR1,VAR2..., WHOFILE lists all variables.
%
% VERSION : 0.90 22.04.04 YM   first release
%
% See also WHO, CATFILENAME

if nargin == 0,  help whofile;  return;  end


vars = {};

% -------------------------------------------------------------
if ischar(varargin{1}) && strcmpi(varargin{1}(end-3:end),'.mat');
  % WHOFILE(FILENAME,...)
  filename = varargin{1};
  if nargin > 1,
    vars = varargin(2:end);
  end
else
  % WHOFILE(SES,EXPNO/GRPNAME)
  Ses = goto(varargin{1});
  if ischar(varargin{2}),
    % 2nd arg as group name
    filename = sprintf('%s.mat',varargin{2});
  else
    % 2nd arg as experiment number.
    filename = catfilename(Ses,varargin{2},'mat');
  end
  if nargin > 2,
    vars = varargin(3:end);
  end
end


if nargout,
  if ~exist(filename,'file'),
    varargout{1} = {};
  elseif isempty(vars),
    varargout{1} = who('-file',filename);
  else
    varargout{1} = feval(@who,'-file',filename,vars{:});
  end
else
  if ~exist(filename,'file'),
  elseif isempty(vars),
    who('-file',filename)
  else
    feval(@who,'-file',filename,vars{:})
  end
end


return
