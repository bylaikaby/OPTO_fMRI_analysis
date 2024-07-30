function type = ismovie(varargin)
%ISMOVIE - Returns whether the stimulus was a movie-clip
% ISMOVIE(grp) returns type for a group
% ISMOVIE(SESSION,GrpName) returns type for group of session
% ISMOVIE(SESSION,ExpNo) returns type for exp. of session
% NKL, 01.06.03
% YM,  30.01.12 supports mcgroup.

if nargin == 0,  help ismovie; return;  end

if nargin == 1,
  % called like ismovie(grp)
  grp = varargin{1};
else
  % called like ismovie(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup')
  type = grp.ismovie();
  return
end


% old structure style
if any(strncmp('movie',grp.stminfo,5)),
  type=1;
else
  type=0;
end;
