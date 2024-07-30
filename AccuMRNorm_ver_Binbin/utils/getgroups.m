function grp = getgroups(SESSION,IncludeSpecialGroups)
%GETGROUPS - Returns a cell-array of all group-structures of a session
%	grp = GETGROUPS(SESSION), converts Ses.grp.name... into an array of struct
%	with group names, exps, etc as fields
%
%	Group Example
%	========================================================================
%	fix.exps		= [1:25];
%	fix.expinfo	= {'recording';'imaging'}; 
%	fix.stminfo	= 'Polars 100%';                
%	fix.hwinfo	= 'gain 30';
%	fix.imginfo	= {[64 64 2]; '1-Shot EPI,83ms interslice'};
%	fix.epiidx	= [1 2];                
%	fix.anaidx	= {'mdeft';1};
%	fix.eleidx	= {'gefi';1};
%	fix.imgcrop	= [15 5 25 20];
%	fix.adfoffset	= 6;
%	fix.adflen	= 128;
%	fix.v			= [];
%	fix.t			= [];
% ========================================================================
%
%	NKL, 21.10.02
%	YM,  21.12.05  use getgrp() to get group structure.

if nargin == 0,  help getgroups; return;  end

if nargin < 2,
  IncludeSpecialGroups = 0;
end
if ischar(IncludeSpecialGroups),
  if any(strcmpi(IncludeSpecialGroups,{'all','include','IncludeSpecialGroups'})),
    IncludeSpecialGroups = 1;
  else
    IncludeSpecialGroups = 0;
  end
end


Ses = getses(SESSION);
if IncludeSpecialGroups == 0,
  sg = {'autoplot';'test';'misc'};
else
  sg = {};
end

grp = {};
%names = getgrpnames(Ses);
names = fieldnames(Ses.grp);
for N = 1:length(names),
  % skip if the current group is in the special group.
  if any(strcmpi(sg,names{N})),
    continue;
  end
  grp{end+1} = getgrp(Ses,names{N});
end

return;
