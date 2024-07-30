function fsound = mksound(Sig,name)
%MKSOUND - Make a wave file and dump on f:/Talks/Movies
%	fsound = mksound(Sig,name)
%	NKL, 12.10.00

% Get directories (host-dependent)

HOSTNAME = evalc('!hostname');
HOSTNAME = deblank(char(HOSTNAME(1:6)));
switch HOSTNAME,
case {'nklwin'},		% Nikos Desktop
   sounddir	= 'f:/Talks/Movies';
case {'win42'},			% Nikos Laptop
   sounddir	= 'f:/Talks/Movies';
case {'win58'},			% Nikos Matlab-computer #1
   sounddir	= 'f:/Talks/Movies';
case {'win59'},			% Nikos Matlab-computer #2
   sounddir	= 'f:/Talks/Movies';
otherwise,
   error(sprintf('showcat: unknown HOSTNAME= ''%s''\n'));
end;

fsound = hnanmean(Sig.dat,2);
maxs = max(abs(fsound));
fsound = 0.99 * (fsound ./ maxs);			% to avoid clipping etc..

if (nargin < 2),
	wavplay(fsound,1/Sig.dx);
else
	fpath = sprintf('%s/%s', sounddir, name);
	wavwrite(fsound, 1/Sig.dx, fpath);
end;

