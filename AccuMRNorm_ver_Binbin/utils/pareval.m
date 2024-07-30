function pareval(PAR)
%PAREVAL - Evaluate parameters passed as a structure.
%	usage: pareval(PAR) returns evaluated parameters to the caller
%	INPUT:	PAR = structure
%	OUTPUT:	The fieldnames of PAR will be declared as variables with
%				the corresponding values in the calling function.
%
%	NKL, 10.10.02

tmp = fieldnames(PAR);		% cell array of strings.
if isa(tmp,'char'), tmp = {tmp}; end;
for n = 1:length(tmp),
	assignin('caller', tmp{n}, getfield(PAR,tmp{n}));
end;
return;
