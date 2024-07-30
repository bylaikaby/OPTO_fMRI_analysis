function ws = cdws
%CDWS - Go to the workspace directory
%	ws = CDWS changes the current directory to be ./DataMatlabe/workspace
%	cd ./matlab/workspace
%	NKL, 02.02.99

DIRS = getdirs;
cd(DIRS.WORKSPACE);
if nargout,
	ws = DIRS.WORKSPACE;
end;
