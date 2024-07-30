function type = isnormal(varargin)
%ISNORMAL - Returns whether is a recording/imaging group was normal (Control)
% ISNORMAL(grp) returns type for a group
% ISNORMAL(SESSION,GrpName) returns type for group of session
% ISNORMAL(SESSION,ExpNo) returns type for exp. of session
% NKL, 01.06.03
% YM,  30.01.12 supports mcgroup.

if nargin == 0,  help isnormal; return;  end

if nargin == 1,
  % called like isnormal(grp)
  grp = varargin{1};
else
  % called like isnormal(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup')
  type = grp.isnormal();
  return
end


% old structure style
if any(strcmp('normal',grp.condition)),
  type=1;
else
  type=0;
end;
