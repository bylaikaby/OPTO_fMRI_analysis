function type = isinjection(varargin)
%ISINJECTION - Returns whether a group was collected during or after inection (anesth, neuromod)
% ISINJECTION(grp) returns type for a group
% ISINJECTION(SESSION,GrpName) returns type for group of session
% ISINJECTION(SESSION,ExpNo) returns type for exp. of session
% NKL, 1.06.03

if nargin == 0,  help isinjection; return;  end

if nargin == 1,
  % called like isinjection(grp)
  grp = varargin{1};
else
  % called like isinjection(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.isinjection();
  return
end


% old structure style
if isfield(grp,'condition') & any(strcmp('injection',grp.condition)),
  type=1;
else
  type=0;
end;


if isfield(grp,'expinfo') & any(strcmp('injection',grp.expinfo)),
  type=1;
else
  type=0;
end;
