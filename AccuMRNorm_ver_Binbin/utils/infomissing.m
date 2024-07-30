function [mfiles,DirFiles] = infomissing(SESSION,FileType)
%INFOMISSING - Display missing mat files from a session
%	INFOMISSING(SESSION) Examines the directory of the session and finds out which
%	experiments were not cleaned/analyzed.
%	NKL 19.05.05
%
%	See also SESHELP

if nargin < 2,
  FileType = 'Cln';
end;

if ~exist('FileType'),
  fprintf('CHECK infomissing CODE\n');
  return;
end;

Ses = goto(SESSION);
grpnames = getgrpnames(Ses);

if strcmp(FileType,'Cln') | strcmp(FileType,'ClnSpc'),
  cd SIGS;
end;

files = dir;
exps = validexps(Ses);
exps = sort(exps);

K=1;
for N=1:length(files),
  if strncmp(files(N).name,Ses.name,length(Ses.name)),
    DataFile{K} = files(N).name;
    K=K+1;
  end;
end;

for N=1:length(Ses.expp),
  [PATHSTR,NAME] = fileparts(Ses.expp(N).physfile);
  sesfiles{N} = strcat(NAME,'_',upper(FileType),'.mat');
end;

K=1;
for N=1:length(exps),
  ExpNo = exps(N);
  if ~any(strcmp(sesfiles{ExpNo},DataFile)),
    MissingFiles{K}=sesfiles{ExpNo};
    K=K+1;
  end;
end;

if nargout,
  mfiles = MissingFiles;
  if nargout == 2,
    DirFiles = DataFile;
  end;
else
  for N=1:length(MissingFiles),
    fprintf('%s\n', MissingFiles{N});
  end;
end;
