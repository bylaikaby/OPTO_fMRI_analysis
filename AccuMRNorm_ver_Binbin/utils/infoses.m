function s = infoses(SESSION)
%SESINFO - Information on Groups & Experiments of a Session
%	SESINFO(SESSION) Reads the session description file and display
%	all important information of a session. It includes, filenames,
%	experiments, image and neurophsyiology parameters etc.
%	NKL 13.02.03
%
%	See also SESHELP CLNHELP
  
%           name: 'ratai2'
%           date: '26.Oct.11'
%       grpnames: {3x1 cell}
%           exps: {[1x40 double]  [47 48 49 50]  [1 2 3 4 5 6]}
%       elesites: {{1x11 cell}  {1x11 cell}  {1x11 cell}}
%       elenames: {{1x5 cell}  {1x5 cell}  {1x5 cell}}
%      recording: [1 1 1]
%        imaging: [1 1 0]
%       grpspont: {2x1 cell}
%        anatomy: {'rare'}
%     StructName: {{1x2 cell}  {1x2 cell}  {1x2 cell}}
    
Ses = goto(SESSION);
s.name = SESSION;
s.date = Ses.sysp.date;
s.grpnames = getgrpnames(Ses);
for N=1:length(s.grpnames),
  grp = getgrp(SESSION, s.grpnames{N});
  s.exps{N} = grp.exps;
  s.elenames{N} = unique(grp.ele.site);
  s.elesites{N} = grp.ele.site;
  s.recording(N)=0;
  s.imaging(N)=0;
  if (find(strcmpi(grp.expinfo,'recording'))), s.recording(N) = 1; end;
  if (find(strcmpi(grp.expinfo,'imaging'))), s.imaging(N) = 1; end;

end;
idx = find(strncmp(s.grpnames,'spon',4));
s.grpspont = s.grpnames(idx);

if isfield(Ses,'ascan') & ~isempty(Ses.ascan),
  s.anatomy = fieldnames(Ses.ascan);
end

for N=1:length(s.grpnames),
  STRUCTURES{N} = {};
  if find(strcmpi(s.elenames{N},'pl')),  STRUCTURES{N}{end+1} = 'hip'; end;
  if find(strcmpi(s.elenames{N},'th')),  STRUCTURES{N}{end+1} = 'tha'; end;
  if find(strcmpi(s.elenames{N},'lc')),  STRUCTURES{N}{end+1} = 'lc'; end;
  if find(strcmpi(s.elenames{N},'cx')),  STRUCTURES{N}{end+1} = 'cx'; end;
  if find(strcmpi(s.elenames{N},'pfc')), STRUCTURES{N}{end+1} = 'pfc'; end;
end;
s.StructName = STRUCTURES;

if ~nargout,
  txt1 = sprintf('%s ', s.grpnames{:});
  txt2 = sprintf('%s ', s.grpspont{:});
  fprintf('%s(%s) = {%s}\n', upper(s.name), s.date, txt1);
  fprintf('%s(Spont Act) = {%s}\n', upper(s.name), txt2);

  fprintf('STRUCTURES\n');
  for N=1:length(s.grpnames),
    fprintf('\t%-10s: ', upper(s.grpnames{N}));
    fprintf('%s ', s.StructName{N}{:});
    fprintf('\n');
  end;
  
  fprintf('ELECTRODE-NAMES\n');
  for N=1:length(s.grpnames),
    fprintf('\t%-10s: ', upper(s.grpnames{N}));
    fprintf('%s ', s.elenames{N}{:});
    fprintf('\n');
  end;
  
  fprintf('ELECTRODE-SITES (Tip-Locations)\n');
  for N=1:length(s.grpnames),
    fprintf('\t%-10s: ', upper(s.grpnames{N}));
    fprintf('%s ', s.elesites{N}{:});
    fprintf('\n');
  end;
  
  
end;

return;




