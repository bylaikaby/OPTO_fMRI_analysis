function type = isspectroscopy(varargin)
%ISSPECTROSCOPY - Returns whether is a spectroscopy session
% ISSPECTROSCOPY(grp) returns type for a group
% ISSPECTROSCOPY(SESSION,GrpName) returns type for group of session
% ISSPECTROSCOPY(SESSION,ExpNo) returns type for exp. of session
%
%  EXAMPLE :
%    >> isspectroscopy('ratpE2',1)
%    >> isspectroscopy('ratpE2','spont')
%    >> isspectroscopy(getgrp('ratpE2','spont'))
%
%  VERSION :
%    0.90 12.05.14 YM  pre-release
%
%  See also isimaing isrecording


if nargin == 0,  help isspectroscopy; return;  end

if nargin == 1,
  % called like isspectroscopy(grp)
  grp = varargin{1};
else
  % called like isspectroscopy(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  type = grp.isspectroscopy();
  return
end

% old structure style
if isfield(grp,'expinfo') & any(strcmp('spectroscopy',grp.expinfo)),
  type=1;
else
  type=0;
end;
