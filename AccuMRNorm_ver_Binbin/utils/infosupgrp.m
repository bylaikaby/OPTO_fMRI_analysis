function s = infosupgrp(SESSION)
%INFOSUPGRP - Lists & returns all super groups from description files
% s = INFOSUPGRP (SESSION)
% NKL 01.11.03

global SupGrps
SupGrps = {'SuperGrps','ImgGrps','chcfGrps','winGrps'};
Ses = goto(SESSION,1);

s.session = Ses.name;
for K=1:length(SupGrps),
  if isfield(Ses,SupGrps{K}),
    eval(sprintf('tmp = Ses.%s;',SupGrps{K}));
    if ~strcmp(SupGrps{K},'winGrps'),
      if isempty(tmp), continue; end;
      if isempty(tmp{1}), continue; end;
      if isempty(tmp{1}{1}), continue; end;
      eval(sprintf('s.%s = Ses.%s;',SupGrps{K},SupGrps{K}));
    else
      eval(sprintf('s.%s = Ses.%s;',SupGrps{K},SupGrps{K}));
    end;
  end;
end;
DisplayStructures(s);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function DisplayStructures(ses)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
global SupGrps SFN03DIR
fnames = fieldnames(ses);
fprintf('SESSION: %s\n', ses.session);
for K=2:length(fnames),
  if strcmp(fnames{K},'winGrps'),
    eval(sprintf('tmp = ses.%s;', fnames{K}));
    % NUMBER OF EACH GROUP (SuperGrps{1}, {2}, etc.)
    for F=1:length(tmp),
      fprintf('%12s(%d) = ', fnames{K},F);
      fprintf('%s ', tmp{F}{:});
      fprintf('\n');
    end;
  else
    eval(sprintf('tmp = ses.%s;', fnames{K}));
    % NUMBER OF EACH GROUP (SuperGrps{1}, {2}, etc.)
    for F=1:length(tmp),
      fprintf('%12s(%d) = %s: ', fnames{K}, F, char(tmp{F}{1}));
      fprintf('%s ', tmp{F}{2}{:});
      fprintf('\n');
    end;
  end;
end;
return;


