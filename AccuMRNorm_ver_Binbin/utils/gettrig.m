function pat = gettrig(Sig,Pattern,Trigger,PreTime,PosTime,ModelNo)
%GETTRIG - get patterns "Pattern" from obsp with Trig/Pre/Pos specs
%	pat = GETTRIG(Sig,Pattern,Trigger,PreTime,PosTime,ModelNo), finds occurrences of
%	a given pattern in the observation period and returns its time and
%	duration in SECONDS. It is used for collapsing observation periods in averaged
%	trials.
%	
%	e.g. p = gettrig(Sig,[0 1 0],1,20,30,1), 20/30 in seconds
%	The function is usually called before the actual time courses of
%	the patterns are extracted with gettrgtrial().
%	Typical usage:
%	p = gettrig(img, [0 K 0], K, PRETIME, POSTTIME);
%	tc{N}{K} = gettrgtrial(img,p);
%	
%	NKL, 13.12.01

if nargin < 6,
	ModelNo = 1;
end;

if nargin < 2,
	error('usage: gettrig(SESSION,Pattern,Trigger,PreTime,PosTime,ModelNo);');
	return;
end;

TrigIdx = -1;
for K=1:length(Pattern),
	if Pattern(K) == Trigger,
		TrigIdx = K;
		break;
	end;
end;
if TrigIdx < 0,
	fprintf('Trigger must be one of the number in pattern!\n');
	keyboard;
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
idx = idx + TrigIdx - 1;

pat.pattern = Pattern;			% e.g. [0 1 0 2 0]
pat.trigger = Trigger;			% 2
pat.trigidx = idx;				% 4
pat.stmt = t(idx);

pat.stm{ModelNo}.v = Pattern;
pat.stm{ModelNo}.t = [PreTime; t(2); PosTime];
pat.stm{ModelNo}.stm = cumsum([0; PreTime; t(2)]);

for N=1:length(idx),
	pat.trig(N) = stmt(idx(N));
	pat.pret(N) = pat.trig(N) - PreTime;
	pat.post(N) = pat.trig(N) + PosTime;
	if pat.pret(N) < 0 | pat.post(N) < 0,
		fprintf('Error: Negative times\n');
		keyboard;
	end;
end;


