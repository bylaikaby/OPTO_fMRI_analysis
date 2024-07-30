function type = isoptimaging(varargin)
%ISOPTIMAGING - Returns whether is a group of optimaging data
% ISOPTIMAGING(grp) returns type for a group
% ISOPTIMAGING(SESSION,GrpName) returns type for group of session
% ISOPTIMAGING(SESSION,ExpNo) returns type for exp. of session
% YM, 09.06.11
% YM, 30.01.12 supports mcgroup.

if nargin == 0,  help isoptimaging; return;  end

if nargin == 1,
  % called like isoptimaging(grp)
  grp = varargin{1};
else
  % called like isoptimaging(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.isoptimaging();
  return
end


% old structure style
if isfield(grp,'expinfo') && any(strcmpi('optimaging',grp.expinfo)),
  type=1;
elseif isfield(grp,'optimag') && ~isempty(grp.optimag),
  type=1;
else
  type=0;
end
