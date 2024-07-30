function out = parseinput(regexp, varargin)
%PARSEINPUT - Finds first string argument.
% val = PARSEINPUT(regexp, args) returns the value of the regular expression regexp
% NKL 31.07.04
% NKL 31.12.05
  
out = [];
if isempty(varargin{1}),
  return;
end;

if length(varargin{1}) == 1,
  fprintf('PARSEINPUT: No value for property "%s"\n', char(varargin{1}));
  return;
end;

varargin = varargin{1};
for N=1:2:length(varargin),
  idx = [];
  for R = 1:length(regexp),
    idx = find(strcmp(varargin{N},regexp{R}));
    if ~isempty(idx), break; end;
  end;

  if isempty(idx),
    fprintf('PARSEINPUT: Bad property "%s"\n', char(varargin{N}));
    out = [];
    return;
  end;
  
  tmp = varargin{N+1};
  eval(sprintf('out.%s = tmp;', varargin{N}));

end;

% I CAN FIX THIS LATER...
% For now the function returns the structure out and the caller must evaluate the fieldnames
% and fields.
%
% nam = fieldnames(out);
% for N=1:length(nam),
%   tmp = getfield(out,nam{N});
%   eval(sprintf('%s=tmp;', nam{N}));
%   evalin('caller',sprintf('%s;'));
% end;
