function infoanagroups(SesName)
%INFOANAGROUPS - Information needed to prepare ANAP.ANAGROUPS and ANAP.STS
% INFOANAGROUPS (SesName) This function is meant to be used before we fill in the anagroups
% and sts structures of ANAP. After preparing the fields of these structures, INFOANAGROUPS
% will show their contents, instead of listing all models in ANAP.glmana, etc.
%
% See also INFOSTAT
%
% NKL 06.10.06

if nargin < 1,
  help infoanagroups;
  return;
end;

Ses = goto(SesName);
anap = getanap(Ses);
if ~isfield(anap,'anagroups'),
  fprintf('INFOANAGROUPS: Description file %s does not have an ANAP.anagroups entry!\n', ...
          SesName);
  return
end;

fprintf('ANAP.anagroups = {');
fprintf('''%s'',', anap.anagroups{1:end-1});
fprintf('''%s''', anap.anagroups{end});
fprintf('};\n');
if isfield(anap,'sts'),
  names = fieldnames(anap.sts);
  for N=1:length(names),
    eval(sprintf('contrasts = anap.sts.%s{1};', names{N}));
    fprintf('%s: ', upper(names{N}));
    fprintf('%s ', contrasts{:});
    fprintf('\n');
  end;
else
  for N=1:length(anap.anagroups),
    grp = getgrpbyname(Ses,anap.anagroups{N});
    mdl = grp.glmana;
    glm = grp.glmconts;
    
    names = '';
    for K=2:length(glm)-1,      % First is always General Effects (f values)
      names = strcat(names,sprintf('''%s'',',glm{K}.name));
    end;
    names = strcat(names,sprintf('''%s''',glm{K+1}.name));
    fprintf('ANAP.sts.%s = {{%s}, {}, [], %3.4f};', anap.anagroups{N},names,anap.mview.alpha);
    fprintf('\n');
  end;
end;




    


