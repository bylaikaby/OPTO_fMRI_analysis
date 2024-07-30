function type = isdicom(varargin)
%ISDICOM - Returns whether is a group of DICOM data
% ISDICOM(grp) returns type for a group
% ISDICOM(SESSION,GrpName) returns type for group of session
% ISDICOM(SESSION,ExpNo) returns type for exp. of session
% YM, 23.07.10
% YM, 30.01.12 supports mcgroup

if nargin == 0,  help isdicom; return;  end

if nargin == 1,
  % called like isdicom(grp)
  grp = varargin{1};
else
  % called like isdicom(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.isdicom();
  return
end


% old structure style
if any(strcmpi(grp.expinfo,'dicom')),
  type=1;
else
  type=0;
end;
