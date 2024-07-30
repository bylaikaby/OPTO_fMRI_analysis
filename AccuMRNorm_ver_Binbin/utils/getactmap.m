function ActMap = getactmap(SesName)
%GETACTMAP - Returns all references groups of a session
% GETACTMAP (SesName) returns all the groups, whose average
% tcImg was used to generate activation maps. For details see the
% HROI documentation. Briefly, each groups has a field named
% "actmap" that indicated the experiment-group used to generate a
% reference map. Groups may have the same or differnet reference
% maps.
% See also HROI MCORANA GETGRPROI

Ses = goto(SesName);
grps = getgroups(Ses);
K = 1;
PreviousGrp = {'none',-1};
for N=1:length(grps),
  if ~isfield(grps{N},'actmap'),
    fprintf('GETACTMAP: Each group MUST have an actmap field\n');
    fprintf('GETACTMAP: Edit your description file\n');
    keyboard;
  end;
  if length(grps{N}.actmap) < 2,
    grps{N}.actmap{2} = -1;          % No trials
  end;
  
  if strcmp(grps{N}.actmap{1},PreviousGrp{1}) & ...
        grps{N}.actmap{2} == PreviousGrp{2},
    continue;
  end;
  ActMap{K} = grps{N}.actmap;
  PreviousGrp = ActMap{K};
  K = K + 1;
end;

