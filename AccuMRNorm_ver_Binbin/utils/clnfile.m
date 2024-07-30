function clnfile(SESSION,GrpName,VarNames)
%CLNFILE - Cleans files by removing any variables except those defined in VarNames
% CLNFILE (SESSION,GrpName,VarNames) gets rid of accidentally saved variables. It loads all
% variables obtained by sigload(Ses,ExpNo), and save thems directly without "append".
%
% NKL, 07.01.06

Ses = goto(SESSION);

if nargin < 3,
  VarNames = {'Spkt';'Sdf';'blp';'tblp';'roiTs';'troiTs'};
end;

if nargin < 2,
  grps = getgroups(Ses);
else
  grps{1} = getgrpbyname(Ses,GrpName);
end;

for GrpNo = 1:length(grps),
  grp = grps{GrpNo};
  for N=1:length(grp.exps),
    ExpNo = grp.exps(N);
    filename=catfilename(Ses,ExpNo,'mat');
    sigload(Ses,ExpNo);
    saved=0;
    fprintf('%s(%d): Saving vars: ',grp.name,ExpNo);
    for V=1:length(VarNames),
      if exist(VarNames{V},'var'),
        if ~saved,
          save(filename,VarNames{V});
        else
          save(filename,'-append',VarNames{V});
        end;
        fprintf('.%s',VarNames{V});
        saved = 1;
      end;
    end;
    fprintf('\n');
  end;
end;


