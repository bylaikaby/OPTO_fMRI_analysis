function matassoc()
%MATASSOC - Associate MAT-files with MATLAB. 
%  MATASSOC() associates MAT-files with MATLAB. 
%
%  NOTES :
%    http://www.mathworks.de/support/solutions/en/data/1-VW0R7/?solution=1-VW0R7
%
%  VERSION :
%    0.90 26.09.12 pre-release
%
%  See also fileassoc

commandwindow;
cwd=pwd;
cd([matlabroot '\toolbox\matlab\winfun\private']);
fileassoc('add','.mat') ;
cd(cwd);
disp('Changed Windows file association. MAT-files are now associated with MATLAB.')
