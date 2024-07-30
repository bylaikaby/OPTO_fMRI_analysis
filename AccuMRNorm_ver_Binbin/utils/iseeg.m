function IS_EEG = iseeg(varargin)
%ISEEG - Returns whether is EEG experiment or not.
%  IS_EEG = ISEEG(grp)
%  IS_EEG = ISEEG(SESSION,GrpName)
%  IS_EEG = ISEEG(SESSION,ExpNo) returns 1 if the given group/exp is
%  the EEG experiment(s), otherwise returns 0.
%
%  EXAMPLE :
%    bIsEEG = iseeg('m02lx1',1)
%
%  VERSION :
%    0.90 25.04.13 YM  pre-release
%
%  See also getses getgrp

if nargin == 0,  help iseeg; return;  end

if nargin == 1,
  % called like iseeg(grp)
  grp = varargin{1};
  Ses = getses(grp.session);
else
  % called like iseeg(ses,exp)
  Ses = getses(varargin{1});
  grp = getgrp(Ses,varargin{2});
end

if isa(grp,'mcgroup'),
  IS_EEG = grp.eeg();
  return
end


% old structure style
if any(strcmpi(grp.expinfo,'eeg')),
  IS_EEG = 1;
elseif isfield(Ses,'expp') && length(Ses.expp) >= grp.exps(end) && ...
      isfield(Ses.expp(grp.exps(1)),'eegfile') && any(Ses.expp(grp.exps(1)).eegfile),
  IS_EEG = 1;
else
  IS_EEG = 0;
end;
