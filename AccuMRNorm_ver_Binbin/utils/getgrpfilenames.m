function names = getgrpfilenames(Ses)
%GETGRPFILENAMES - Returns a cell-array of a session's groupfile-names
%	names = GETGRPFILENAMES return group names
%	NKL, 30.11.02

if ischar(Ses), Ses = goto(Ses);  end
names = getgrpnames(Ses);
for N=1:length(names),
  names{N} = strcat(names{N},'.mat');
end;
