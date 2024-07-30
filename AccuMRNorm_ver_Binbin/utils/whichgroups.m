function whichgroups(SESSION)
%WHICHGROUPS - List all groups of a session
%
% NKL, 10.10.00; 12.04.04

if nargin < 1,
  help whichgroups;
  return;
end;

Ses = goto(SESSION);

grps=getgroups(Ses);

for N=1:length(grps),
  names{N} = grps{N}.name;
end;
fprintf('%s\n', upper(Ses.name));
fprintf('%s ', names{:});
fprintf('\n\n');
return;
