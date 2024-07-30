function type = isimaging(varargin)
%ISIMAGING - Returns whether is a recording/imaging session
% ISIMAGING(grp) returns type for a group
% ISIMAGING(SESSION,GrpName) returns type for group of session
% ISIMAGING(SESSION,ExpNo) returns type for exp. of session
% NKL, 01.06.03
% YM,  30.01.12 supports mcgroup.

if nargin == 0,  help isimaging; return;  end

if nargin == 1,
  % called like isimaging(grp)
  grp = varargin{1};
else
  % called like isimaging(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.isimaging();
  return
end

% old structure style
if isfield(grp,'expinfo') & any(strcmp('imaging',grp.expinfo)),
  type=1;
else
  type=0;
end;
