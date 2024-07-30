function type = isspike2(varargin)
%ISSPIKE2 - Returns whether is a group of spike2 data
% ISSPIKE2(grp) returns type for a group
% ISSPIKE2(SESSION,GrpName) returns type for group of session
% ISSPIKE2(SESSION,ExpNo) returns type for exp. of session
% YM, 09.06.10
% YM, 30.01.12 supports mcgroup.

if nargin == 0,  help isspike2; return;  end

if nargin == 1,
  % called like isspike2(grp)
  grp = varargin{1};
else
  % called like isspike2(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup')
  type = grp.isspike2();
  return
end


% old structure style
if any(strcmpi(grp.expinfo,'spike2')),
  type=1;
elseif isfield(grp,'SPIKE2') && isfield(grp.SPIKE2,'data') && ~isempty(grp.SPIKE2.data),
  type=1;
else
  type=0;
end;
