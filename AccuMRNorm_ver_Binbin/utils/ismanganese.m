function type = ismanganese(varargin)
%ISMANGANESE - Returns whether the manganese experiment or not.
% ISMANGANESE(grp) returns type for a group
% ISMANGANESE(SESSION,GrpName) returns type for group of session
% ISMANGANESE(SESSION,ExpNo) returns type for exp. of session
%
%  VERSION :
%    0.90 18.05.09 YM  pre-release
%    0.91 30.01.12 YM  supports mcgroup.
%
%  See also mcgroup/ismanganese

if nargin == 0,  help ismanganese; return;  end

if nargin == 1,
  % called like ismanganese(grp)
  grp = varargin{1};
else
  % called like ismanganese(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.ismanganese();
  return
end


% old stucture style
if isfield(grp,'mninject') && isfield(grp,'permute') && isfield(grp,'flipdim'),
  type=1;
else
  type=0;
end;
