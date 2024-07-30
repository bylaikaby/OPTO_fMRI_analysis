function GrpNames = getgrproi(SesName)
%GETGRPROI - Returns all references groups of a session
% GETGRPROI (SesName) returns all the groups, whose average
% tcImg was used to generate activation maps. For details see the
% HROI documentation. Briefly, each groups has a field named
% "actmap" that indicated the experiment-group used to generate a
% reference map. Groups may have the same or differnet reference
% maps.
% See also HROI MCORANA GETGRPROI

Ses = goto(SesName);
grps = getgroups(Ses);

for N=1:length(grps),
  if ~isfield(grps{N},'grproi'),
    fprintf('GETGRPROI: Each group MUST have an grproi field\n');
    fprintf('GETGRPROI: Edit your description file\n');
  end;
  GrpNames{N} = grps{N}.grproi;
end;
GrpNames = unique(GrpNames);

