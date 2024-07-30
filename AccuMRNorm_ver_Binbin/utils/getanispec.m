function ani = getanispec(SesName)
%GETANISPEC - Returns the species of the experimenal animal used in SesName
an  = 'monkey';    % Species used for experiments
if (iscell(SesName)&strcmpi(SesName{1},'rat')) | (ischar(SesName)&strncmp(SesName,'rat',3)),
  ani = 'rat';
end;
return;

