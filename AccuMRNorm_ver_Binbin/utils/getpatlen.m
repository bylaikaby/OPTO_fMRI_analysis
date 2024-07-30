function len = getpatlen(Sig,Pattern)
%GETPATLEN - get the length of a pattern (blank-fix-stim-blank) in points
%	pat = GETPATLEN(Sig,Pattern), finds the occurrence of
%	a given pattern and computes its length in points. The function is
%	usually called to estimate the number of lags in correllation analysis.
%	NKL, 13.12.01
%
%	See also GETIMPULSE

ModelNo = 1;

if nargin < 2,
	error('usage: getpatlen(Sig,Pattern);');
	return;
end;

stmt = Sig.stm{ModelNo}.stm;
stmv = Sig.stm{ModelNo}.v;

stmt = stmt(:);
t = diff(stmt);

try,
   K=1;
   for N=1:length(stmv)-length(Pattern)+1,
	   if stmv(N) == Pattern(1),
		   MISS = 0;
		   for P=2:length(Pattern),
			   if Pattern(P) ~= stmv(N+P-1),
				   MISS=1;
				   break;
			   end;
		   end;
		   if ~MISS,
			   idx(K) = N;
			   K = K + 1;
		   end;
	   end;
   end;
catch,
	disp(lasterr);
	keyboard;
end;

N=1;
dt = round(sum(t(idx(N):idx(N)+length(Pattern)-1)));
cnddt = stmt(idx(N)+2) - stmt(idx(N)+1);
t1 = stmt(idx(N)+1) - t(1);
t2 = t1 + dt;
t1 = round(t1 / Sig.dx(1)) + 1;
t2 = round(t2 / Sig.dx(1)) + 1;
len = length([t1:t2]);











