function type = isawake(varargin)
%ISAWAKE - Returns whether a group was collected with awake animals or not
% ISAWAKE(grp) returns type for a group
% ISAWAKE(SESSION,GrpName) returns type for group of session
% ISAWAKE(SESSION,ExpNo) returns type for exp. of session
% YM  06.10.06
% YM  30.01.12  supports mcgroup

if nargin == 0,  help isawake; return;  end

if nargin == 1,
  % called like isawake(grp)
  grp = varargin{1};
else
  % called like isawake(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.isawake();
  return
end

% old structure style
type = 0;
if isfield(grp,'expinfo'),
  if any(strcmp('awake',grp.expinfo)) | any(strcmp('alert',grp.expinfo)),
    type=1;
  end
end

