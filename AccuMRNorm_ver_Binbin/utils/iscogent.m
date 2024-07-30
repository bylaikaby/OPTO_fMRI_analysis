function type = iscogent(varargin)
%ISCOGENT - Returns whether is a group of Cogent stimulation data
% ISCOGENT(grp) returns type for a group
% ISCOGENT(SESSION,GrpName) returns type for group of session
% ISCOGENT(SESSION,ExpNo) returns type for exp. of session
% YM, 23.07.10
% YM, 30.01.12 supports mcgroup

if nargin == 0,  help iscogent; return;  end

if nargin == 1,
  % called like iscogent(grp)
  grp = varargin{1};
else
  % called like iscogent(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.iscogent();
  return;
end


% old structure style
if any(strcmpi(grp.expinfo,'cogent')),
  type=1;
elseif isfield(grp,'COGENT') && isfield(grp.COGENT,'varname') && ~isempty(grp.COGENT.varname),
  type=1;
else
  type=0;
end;

