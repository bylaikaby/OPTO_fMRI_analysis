function pat = getpat(Sig,Pattern,ModelNo)
%GETPAT - get pattern of trials from observation period
%	pat = GETPAT(Sig,Pattern,ModelNo), finds occurrences of
%	a given pattern in the observation period and returns its time and
%	duration in SECONDS. It is used for collapsing observation periods in averaged
%	trials.
%
% NKL, 13.12.01

if nargin < 3,
	ModelNo = 1;
end;

if nargin < 2,
	error('usage: getpat(SESSION,Pattern);');
	return;
end;

stmt = Sig.stm.t{ModelNo};
stmv = Sig.stm.v{ModelNo};

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

for N=1:length(idx),
	if N==1,
		% sum diffs of the relevant intervals (pattern length!)
		dt = round(sum(t(idx(N):idx(N)+length(Pattern)-1)));
	end;
	pat.t1(N) = stmt(idx(N));
	pat.t2(N) = pat.t1(N) + dt;

	pat.stm = Sig.stm;
	pat.v{ModelNo} = Pattern;
	pat.dt{ModelNo} = Sig.stm.dt{ModelNo}(idx(1):idx(1)+length(Pattern)-1);
	pat.t{ModelNo} = stmt(idx(1):idx(1)+length(Pattern)-1);
	pat.t{ModelNo} = pat.t{ModelNo} - stmt(idx(1));
end;




