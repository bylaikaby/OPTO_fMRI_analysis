function ws = cddemo
%CDDEMO - Go to the demo directory
%	ws = CDDEMO changes the current directory to be ./DataMatlabe/workspace
%	cd ./matlab/workspace
%	NKL, 02.02.99

DIRS=getdirs;
demodir = strcat(DIRS.homedir,'Matlab/demo');
cd(demodir);
if nargout,
	ws = demodir;
end;
