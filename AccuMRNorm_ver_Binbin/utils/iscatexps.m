function type = iscatexps(varargin)
%ISCATEXPS - Returns whether a group was "catexps" or not
% ISCATEXPS(grp) returns type for a group
% ISCATEXPS(SESSION,GrpName) returns type for group of session
% ISCATEXPS(SESSION,ExpNo) returns type for exp. of session
%
%  VERSION :
%    0.90 30.01.12 YM  pre-release
%
%  See also sescatexps

if nargin == 0,  help iscatexps; return;  end

if nargin == 1,
  % called like iscatexps(grp)
  grp = varargin{1};
else
  % called like iscatexps(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.iscatexps();
  return
end

% old structure style
type = 0;
if isfield(grp,'catexps') && ~isempty(grp.catexps),
  type = 1;
elseif isfield(grp,'catexps') && isfield(grp.catexps,'exps') && ~isempty(grp.catexps.exps),
  type = 1;
end
