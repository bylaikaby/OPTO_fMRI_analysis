function type = isnifti(varargin)
%ISNIFTI - Returns whether is a group of NIFTI data
% ISNIFTI(grp) returns type for a group
% ISNIFTI(SESSION,GrpName) returns type for group of session
% ISNIFTI(SESSION,ExpNo) returns type for exp. of session
% YM, 23.07.10
% YM, 30.01.12 supports mcgroup.

if nargin == 0,  help isnifti; return;  end

if nargin == 1,
  % called like isnifti(grp)
  grp = varargin{1};
else
  % called like isnifti(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.isnifti();
  return
end


% old structure style
if any(strcmpi(grp.expinfo,'nifti')),
  type=1;
else
  type=0;
end;
