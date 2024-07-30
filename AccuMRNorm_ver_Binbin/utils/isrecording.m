function type = isrecording(varargin)
%ISRECORDING - Returns whether is a recording/imaging session
% ISRECORDING(grp) returns type for a group
% ISRECORDING(SESSION,GrpName) returns type for group of session
% ISRECORDING(SESSION,ExpNo) returns type for exp. of session
% NKL, 01.06.03
% YM,  30.01.12 supports mcgroup.

if nargin == 0,  help isrecording; return;  end

if nargin == 1,
  % called like isrecording(grp)
  grp = varargin{1};
else
  % called like isrecording(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.iselephys();
  return
end


% old structure style
if isfield(grp,'expinfo') & any(strcmp('recording',grp.expinfo)),
  type=1;
else
  type=0;
end;
