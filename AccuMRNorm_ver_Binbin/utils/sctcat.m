function [oSct, rSct] = sctcat(Sct1,Sct2)
%SCTCAT - Conctaneate structures
%	[oSct, rSct] = SCTCAT(Sct1,Sct2)
%	Returns:
%	oSct = Sct1 + new fields in Sct2
%	rSct = Douplicate fields not copied from Sct2 to Sct1
%	NKL, 20.08.00
%
%  See also SCTMERGE

oSct = Sct1;
rSct = [];
Fname = fieldnames(Sct2);
if isa(Fname,'char'), Fname = {Fname}; end;
for i = 1:length(Fname),
   if isfield(Sct1,Fname{i}),	% If a field from Sct2 already exists in Sct1...
      rSct = setfield(rSct, Fname{i}, getfield( Sct2, Fname{i}));
   else,
      oSct = setfield(oSct, Fname{i}, getfield( Sct2, Fname{i}));
   end;
end;
return;
