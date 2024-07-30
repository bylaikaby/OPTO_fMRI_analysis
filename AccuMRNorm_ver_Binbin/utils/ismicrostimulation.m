function type = ismicrostimulation(varargin)
%ISMICROSTIMULATION - Returns whether is a group of microstimulation data
% ISMICROSTIMULATION(grp) returns type for a group
% ISMICROSTIMULATION(SESSION,GrpName) returns type for group of session
% ISMICROSTIMULATION(SESSION,ExpNo) returns type for exp. of session
% NKL, 01.06.03
% YM,  30.01.12 supports mcgroup

if nargin == 0,  help ismicrostimulation; return;  end

if nargin == 1,
  % called like ismicrostimulation(grp)
  grp = varargin{1};
else
  % called like ismicrostimulation(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.ismicrostimulation();
  return
end


% old structure style
if any(strncmpi('microstim',grp.expinfo,9)),
  type=1;
elseif any(strncmpi('stimulation',grp.expinfo,11)),
  type=1;
else
  type=0;
end;
