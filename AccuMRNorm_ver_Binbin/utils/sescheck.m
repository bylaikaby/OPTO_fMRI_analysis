function IsOK = sescheck(SESNAME,CheckLevel)
%SESCHECK - Check a session
% PURPOSE : To check descriptional propriety of a session file.
% USAGE   : sescheck(SESNAME)
%           IsOK = sescheck('n00eb1')
% NOTES   :
% SEEALSO : @SessionTemplate.m
% VERSION : 0.90 23.01.04 YM   basic checks
%           0.91 26.01.04 YM   file checks
%           0.92 11.02.04 YM   adds checking grp.xxx.stmtypes.
%           0.93 03.03.04 YM   adds checking gefi/mdeft/ir.wordtype.
%           0.94 15.04.04 YM   modified for the new session format.
%           0.95 09.02.06 YM   avoid case-sensitive warning on Matlab7.
%           0.96 23.02.06 YM   checks 'reco' and 'acqp' too.
%           0.97 14.06.13 YM   use fullfile() instead of strcat().
%
% See also PROJCHECK @SESSIONTEMPLATE SESCHECKLV2

if nargin < 1,  help sescheck;  return;  end
if nargin < 2,  CheckLevel = 1;  end

IsOK = 0;

fprintf('sescheck: %s\n',SESNAME);

if ~exist(SESNAME)
  fprintf('ERROR: session file ''%s.m'' not found.\n',SESNAME);
  return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMMER CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(' matlab grammer...');
try
  % get SYSP,CTG,ANAP,ASCAN,CSCAN,GRPP,GRP,EXPP etc.
  SessionName = strrep(SESNAME,'.','');  % to allow M02.lx1 style
  % Matlab7 warns upper/lower case of 'SessionName',
  % use which() function to suppers that messesage.
  SessionFile = which(sprintf('%s.m',SessionName));
  if isempty(SessionFile),
    error('%s does not exist!\n',strcat(SessionName,'.m'));
  end;
  [pathstr,SessionName,extstr] = fileparts(SessionFile);
  eval(SessionName);
catch
  fprintf(' mistake(s) found.\n');
  fprintf('%s\n',lasterr);
  return;
end
fprintf(' OK.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYSP check: DataNeuro, DataMri, dirname, date
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(' SYSP.DataNeuro,DataMri,dirname,date, ANAP.Quality...');
% SYSP.DataNeuro
if ~isfield(SYSP,'DataNeuro'),
  fprintf('\nERROR: SYSP.DataNeuro is missing.\n');
  return;
elseif ~ischar(SYSP.DataNeuro) | isempty(SYSP.DataNeuro),
  fprintf('\nERROR: invalid SYSP.DataNeuro : must be a string.\n');
  return;
end
% SYSP.DataMri
if ~isfield(SYSP,'DataMri'),
  fprintf('\nERROR: SYSP.DataMri is missing.\n');
  return;  
elseif ~ischar(SYSP.DataNeuro) | isempty(SYSP.DataNeuro),
  fprintf('\nERROR: invalid SYSP.DataMri : must be a string.\n');
  return;
end
% SYSP.dirname
if ~isfield(SYSP,'dirname'),
  fprintf('\nERROR: SYSP.dirname is missing.\n');
  return;
elseif ~ischar(SYSP.dirname) | isempty(SYSP.dirname),
  fprintf('\nERROR: invalid SYSP.dirname : must be a string.\n');
  return;
elseif ~strcmpi(SESNAME,strrep(SYSP.dirname,'.','')),
  fprintf('\nERROR: session is ''%s'' but SYSP.dirname is ''%s''.\n',...
          SESNAME,SYSP.dirname);
  return;
end
% SYSP.date
if ~isfield(SYSP,'date'),
  fprintf('\nERROR: SYSP.date is missing.\n');
  return;
elseif ~ischar(SYSP.date) | isempty(SYSP.date),
  fprintf('\nERROR: invalid SYSP.date : must be a string.\n');
  return;
end

% ANAP.Quality
if ~isfield(ANAP,'Quality'),
  fprintf('\nERROR: ANAP.Quality is missing.\n');
  return;
elseif ~isnumeric(ANAP.Quality),
  fprintf('\nERROR: invalid ANAP.Quality : must be numeric.\n');
end

fprintf(' OK.\n');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASCAN (ANATOMY SCAN) CHECK : gefi/mdeft/ir/msme
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gefi
if exist('ASCAN','var') & isfield(ASCAN,'gefi') & ~isempty(ASCAN.gefi),
  if ~subCheckAnaScan(SYSP,ASCAN,'gefi'), return;  end
end
% mdeft
if exist('ASCAN','var') & isfield(ASCAN,'mdeft') & ~isempty(ASCAN.mdeft),
  if ~subCheckAnaScan(SYSP,ASCAN,'mdeft'), return;  end
end
% ir
if exist('ASCAN','var') & isfield(ASCAN,'ir') & ~isempty(ASCAN.ir),
  if ~subCheckAnaScan(SYSP,ASCAN,'ir'), return;  end
end
% msme
if exist('ASCAN','var') & isfield(ASCAN,'msme') & ~isempty(ASCAN.msme),
  if ~subCheckAnaScan(SYSP,ASCAN,'msme'), return;  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CSCAN (BASIC FUNCTIONAL SCAN) CHECK : epi13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('CSCAN','var') & isfield(CSCAN,'epi13') & ~isempty(CSCAN.epi13),
  fprintf(' CSCAN.epi13{}...');
  for N = 1:length(CSCAN.epi13),
    fprintf(' %d',N);
    if ~isfield(CSCAN.epi13{N},'info'),
      fprintf('\nERROR: CSCAN.epi13{%d}.info is missing.\n',N);
      return;
    elseif ~ischar(CSCAN.epi13{N}.info),
      fprintf('\nERROR: CSCAN.epi13{%d}.info must be a string.\n',N);
      return;
    end
    if ~isfield(CSCAN.epi13{N},'scanreco'),
      fprintf('\nERROR CSCAN.epi13{%d}.scanreco is missing.\n',N);
      return;
    elseif ~isnumeric(CSCAN.epi13{N}.scanreco) ...
          | length(CSCAN.epi13{N}.scanreco) ~= 2,
      fprintf('\nERROR: CSCAN.epi13{%d}.scanreco must be [scan# reco#].\n',N);
      return;
    end
    if ~isfield(CSCAN.epi13{N},'imgcrop'),
      fprintf('\nERROR: CSCAN.epi13{%d}.imgcrop is missing.\n',N);
      return;
    elseif ~isnumeric(CSCAN.epi13{N}.imgcrop) ...
          | length(CSCAN.epi13{N}.imgcrop) ~= 4,
      fprintf('\nERROR: CSCAN.epi13{%d}.imgcrop must be [x y width height].\n',N);
      return;
    elseif CSCAN.epi13{N}.imgcrop(1) < 1 | CSCAN.epi13{N}.imgcrop(2) < 1,
      fprintf('\nERROR: CSCAN.epi13{%d}.imgcrop(1,2) must be 1 <=x,y<=scan-width.\n',N);
      return;
    end
    if ~isfield(CSCAN.epi13{N},'v'),
      fprintf('\nERROR: CSCAN.epi13{%d}.v is missing.\n',N);
      return;
    elseif ~iscell(CSCAN.epi13{N}.v),
      fprintf('\nERROR: CSCAN.epi13{%d}.v must be a cell array.\n',N);
      return;
    end
    if ~isfield(CSCAN.epi13{N},'t'),
      fprintf('\nERROR: CSCAN.epi13{%d}.t is missing.\n',N);
      return;
    elseif ~iscell(CSCAN.epi13{N}.t),
      fprintf('\nERROR: CSCAN.epi13{%d}.t must be a cell array.\n',N);
      return;
    end
  end
  fprintf(' OK.\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANAP (MOVIE) CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(ANAP,'revcor'),
  fprintf(' ANAP.revcor...');
  if ~isfield(ANAP.revcor,'Frame'),
    fprintf('\nERROR: ANAP.revcor.Frame is missing.\n',N);
    return;
  end
  if ~isfield(ANAP.revcor,'TOFFSET'),
    fprintf('\nERROR: ANAP.revcor.TOFFSET is missing.\n',N);
    return;
  end
  if ~isfield(ANAP.revcor,'LFP_THR'),
    fprintf('\nERROR: ANAP.revcor.LFP_THR is missing.\n',N);
    return;
  end
  if ~isfield(ANAP.revcor,'MUA_THR'),
    fprintf('\nERROR: ANAP.revcor.MUA_THR is missing.\n',N);
    return;
  end
  if ~isfield(ANAP.revcor,'SelRFChan'),
    fprintf('\nERROR: ANAP.revcor.SelRFChan is missing.\n',N);
    return;
  end
  if ~isfield(ANAP.revcor,'MovPos'),
    fprintf('\nERROR: ANAP.revcor.MovPos is missing.\n',N);
    return;
  elseif ~isnumeric(ANAP.revcor.MovPos) | length(ANAP.revcor.MovPos) ~= 4,
    fprintf('\nERROR: ANAP.revcor.MovPos must be [x y width height].\n',N);
    return;
  end
%   if ~isfield(ANAP.revcor,'NO_AVG'),
%     fprintf('\nERROR: ANAP.revcor.NO_AVG is missing.\n',N);
%     return;
%   end
  fprintf(' OK.\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GROUP CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('GRPP','var') & isa(GRPP,'struct'),
  grpdefs = fieldnames(GRPP);
else
  grpdefs = {};
end
if ~exist('GRP','var') & ~isa(GRP,'struct'),
  fprintf('\nERROR: GRP.xxxx structure is missing.\n');
  return;
else
  grpnames = fieldnames(GRP);
  if isempty(grpnames),
    fprintf('\nERROR: no groups are defined in GRP.\n');
    return;
  elseif ~exist('EXPP','var'),
    fprintf('\nERROR: EXPP() doesn''t exist.\n');
    return;
  end
end
for N = 1:length(grpnames),
  gname = grpnames{N};
  fprintf(' GRP.%s...',gname);
  % prepare 'grp'
  grp = eval(sprintf('GRP.%s',gname));
  % append default parameters if needed.
  for K = 1:length(grpdefs),
    if ~isfield(grp,grpdefs{K}),
      eval(sprintf('grp.%s = GRPP.%s;',grpdefs{K},grpdefs{K}));
    end
  end
  if isfield(grp,'catexps'), continue;  end
  
  % parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % daqver : data acquisition version
  if ~isfield(grp,'daqver'),
    fprintf('\nERROR: GRP.%s.daqver is missing.\n',gname);
    fprintf('data acquisition verstion: 2.00=new, 1.00=old\n');
    return;
  end
  % exps : experiment numbers
  if ~isfield(grp,'exps')
    fprintf('\nERROR: GRP.%s.exps is missing.\n',gname);
    return;
  elseif ~isnumeric(grp.exps),
    fprintf('\nERROR: GRP.%s.exps must be a numeric array.\n',gname);
    return;
  end
  % expinfo : experiment info
  if ~isfield(grp,'expinfo')
    fprintf('\nERROR: GRP.%s.expinfo is missing.\n',gname);
    return;
  elseif ~iscell(grp.expinfo),
    fprintf('\nERROR: GRP.%s.expinfo must be a cell array of strings.\n',gname);
    return;
  else
    IsImg = any(strcmpi(grp.expinfo,'imaging'));
    IsRec = any(strcmpi(grp.expinfo,'recording'));
    % expinfo must have 'imaging' or/and 'recording'.
    if IsImg == 0 & IsRec == 0,
      fprintf('\nERROR: invalid GRP.%s.expinfo\n',gname);
      fprintf('add ''imaging'' or/and ''recording''.\n');
      return;
    end
  end
  % stmfino : stimulus info
  if ~isfield(grp,'stminfo'),
    fprintf('\nERROR: GRP.%s.stminfo is missing.\n',gname);
    return;
  elseif ~ischar(grp.stminfo)
    fprintf('\nERROR: GRP.%s.stminfo must be a string.\n',gname);
    return;
  end
  % recording experimets
  if IsRec,
    % hardch : electrode numbers
    if ~isfield(grp,'hardch'),
      fprintf('\nERROR: GRP.%s.hardch is required for recordings.\n',gname);
      return;
    end
  end
  % imaging experiments
  if IsImg,
    % imgcrop : image crop
    if isfield(grp,'imgcrop') & ~isempty(grp.imgcrop),
      if ~isnumeric(grp.imgcrop) | length(grp.imgcrop) ~= 4,
        fprintf('\nERROR: GRP.%s.imgcrop must be [x y with height].\n',gname);
        return;
      elseif grp.imgcrop(1) < 1 | grp.imgcrop(2) < 1,
        fprintf('\nERROR: GRP.%s.imgcrop(1,2) must be 1 <=x,y<=scan-width.\n',gname);
        return;
      end
    end
    % ana : anatomical scan
    if ~isfield(grp,'ana'),
      fprintf('\nERROR: GRP.%s.ana is required for imaging.\n',gname);
      return;
    elseif isempty(grp.ana),
      fprintf('\n!!!WARNING: GRP.%s.ana is empty.!!!',gname);
    elseif ~iscell(grp.ana) | ~ischar(grp.ana{1}) | ~isnumeric(grp.ana{2}),
      fprintf('\nERROR: invalid GRP.%s.ana.\n',gname);
      return;
    elseif ~isfield(ASCAN,grp.ana{1}),
      fprintf('\nERROR: ASCAN.%s doesn''t exist.\n');
      fprintf('Check GRP.%s.ana\n',gname);
      return;
    else
      ana = eval(sprintf('ASCAN.%s',grp.ana{1}));
      if grp.ana{2} <= 0 | grp.ana{2} > length(ana),
        fprintf('\nERROR: invalid 2nd member of GRP.%s.ana.\n',gname);
        fprintf('Must be 1<=value<=%d, or Add ses.%s{%d}.\n',...
                length(ana),grp.ana{1},grp.ana{2});
        return;
      end
    end
  end
  % no-dgz exps must have .v/.t/.stmtypes
  IsDgz = 1;
  if isfield(grp,'v'),
    IsDgz = 0;
    if ~iscell(grp.v),
      fprintf('\nERROR: GRP.%s.v must be a cell array of numeric arrays.\n',gname);
      return;
    elseif ~isfield(grp,'t'),
      fprintf('\nERROR: GRP.%s.t is required.\n',gname);
      return;
    elseif ~isfield(grp,'stmtypes'),
      fprintf('\nERROR: GRP.%s.stmtypes is required.\n',gname);
      return;
    else
      maxstmid = -1;
      for K = 1:length(grp.v),
        maxstmid = max(grp.v{K});
      end
      if maxstmid + 1 > length(grp.stmtypes),
        fprintf('\nERROR: GRP.%s.stmtype or GRPP.stmtypes is invaild.\n',gname);
        fprintf('       Check each stmtypes for grp.%s.v or GRPP.v.\n',gname);
        return
      end
    end
  end
  if isfield(grp,'t'),
    IsDgz = 0;
    if ~iscell(grp.t),
      fprintf('\nERROR: GRP.%s.t must be a cell array of numeric arrays.\n',gname);
      return;
    elseif ~isfield(grp,'v'),
      fprintf('\nERROR: GRP.%s.v is required.\n',gname);
      return;
    end
  end
  fprintf(' IsImg[%d] IsRec[%d] OK.\n',IsImg,IsRec);

  % data files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  grp.name = gname;
  fprintf(' GRP.%s.exps...',gname);
  for K = 1:length(grp.exps),
    ExpNo = grp.exps(K);
    fprintf(' %d',ExpNo);
    if isfield(EXPP(ExpNo),'physfile'),
      physfile = EXPP(ExpNo).physfile;
    else
      physfile = '';
    end
    if isfield(EXPP(ExpNo),'evtfile'),
      evtfile = EXPP(ExpNo).evtfile;
    else
      evtfile = '';
    end
    % if exist, both phys/evt must be similar
    if ~isempty(physfile) & ~isempty(evtfile),
      [fp,fr1] = fileparts(physfile);
      [fp,fr2] = fileparts(evtfile);
      if ~strcmp(fr1,fr2),
        fprintf('\nERROR: EXPP(%d).physfile/evtfile must be similar.\n',ExpNo);
        return;
      end
    end
    % dgz
    if IsDgz | IsRec,
      if isempty(evtfile) & isempty(physfile),
        fprintf('\nERROR: invalid EXPP(%d).physfile or evtfile.\n',ExpNo);
        return;
      end
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'evt'),
        if isfield(EXPP(ExpNo),'evtfile'),
          fprintf('Check SYSP.DataNeuro, EXPP(%d).evtfile.\n',ExpNo);
        else
          fprintf('Check SYSP.DataNeuro, EXPP(%d).physfile.\n',ExpNo);
        end
        return;
      end
    end
    % adf/adfw
    if IsRec,
      if isempty(physfile),
        fprintf('\nERROR: invalid EXPP(%d).physfile.\n',ExpNo);
        return;
      end
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'phys'),
        fprintf('Check SYSP.DataNeuro, EXPP(%d).physfile.\n',ExpNo);
        return;
      end
    end
    % video signal of adf/adfw
    if isfield(EXPP(ExpNo),'videofile'),
%       if ~subCheckRawFile(ses,EXPP,ExpNo,'vsig'),
%         fprintf('Check ses.DataNeuro, EXPP(%d).videofile.\n',ExpNo);
%         return;
%       end
    end
    % 2dseq
    if IsImg,
      if isfield(EXPP(ExpNo),'scanreco'),
        scanreco = EXPP(ExpNo).scanreco;
      else
        scanreco = [];
      end
      if ~isnumeric(scanreco) | length(scanreco) ~= 2,
        fprintf('\nERROR: EXPP(%d).scanreco must be [scan# reco#]\n',ExpNo);
        return;
      end
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'2dseq'),
        fprintf('Check SYSP.DataMri, EXPP(%d).scanreco.\n',ExpNo);
        return;
      end
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'acqp'),
        fprintf('Check SYSP.DataMri, EXPP(%d).scanreco.\n',ExpNo);
        return;
      end
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'reco'),
        fprintf('Check SYSP.DataMri, EXPP(%d).scanreco.\n',ExpNo);
        return;
      end
    end
    % stm/pdm/hst
    if grp.daqver >= 2 & IsDgz == 1,
      stmdir = fullfile(SYSP.DataNeuro,SYSP.dirname,'/stmfiles/');  
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'stm'),
        fprintf('Check SYSP.DataNeuro, EXPP(%d).physfile, ''%s''.\n',...
                ExpNo,stmdir);
        return;
      end
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'pdm'),
        fprintf('Check SYSP.DataNeuro, EXPP(%d).physfile, ''%s''.\n',...
                ExpNo,stmdir);
        return;
      end
      if ~subCheckRawFile(SYSP,EXPP,ExpNo,'hst'),
        fprintf('Check SYSP.DataNeuro, EXPP(%d).physfile, ''%s''.\n',...
                ExpNo,stmdir);
        return;
      end
    end
  end
  fprintf(' OK.\n');
end


% CheckLevel <=1 examination has been passed.
if CheckLevel <= 1,
  IsOK = 1;  % GOOD! PASSED EXAM.
  fprintf('sescheck: Level1 PASSED.\n');
  %if nargout, varargout{1} = IsOK;  end
  return;
end

%if nargout,
  %[varargout{:}] = sescheckLv2(SESNAME,CheckLevel);
  IsOK = sescheckLv2(SESNAME,CheckLevel);
%else
%  sescheckLv2(SESNAME,CheckLevel);
%end

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RET = subCheckAnaScan(SYSP,ASCAN,aname)
RET = 0;
fprintf(' ASCAN.%s{}...',aname);
ascan = eval(sprintf('ASCAN.%s',aname));
for N = 1:length(ascan),
  fprintf(' %d',N);
  if ~isfield(ascan{N},'info'),
    fprintf('\nERROR: ASCAN.%s{%d}.info is missing.\n',aname,N);
    return;
  elseif ~ischar(ascan{N}.info),
    fprintf('\nERROR: ASCAN.%s{%d}.info must be a string.\n',aname,N);
    return;
  end
  if ~isfield(ascan{N},'scanreco'),
    fprintf('\nERROR ASCAN.%s{%d}.scanreco is missing.\n',aname,N);
    return;
  elseif ~isnumeric(ascan{N}.scanreco) | length(ascan{N}.scanreco) ~= 2,
    fprintf('\nERROR: ASCAN.%s{%d}.scanreco must be [scan# reco#].\n',aname,N);
    return;
  end
  if ~isfield(ascan{N},'imgcrop'),
    fprintf('\nERROR: ASCAN.%s{%d}.imgcrop is missing.\n',aname,N);
    return;
  elseif ~isnumeric(ascan{N}.imgcrop) | length(ascan{N}.imgcrop) ~= 4,
    fprintf('\nERROR: ASCAN.%s{%d}.imgcrop must be [x y width height].\n',aname,N);
    return;
  elseif ascan{N}.imgcrop(1) < 1 | ascan{N}.imgcrop(2) < 1,
    fprintf('\nERROR: ASCAN.%s{%d}.imgcrop(1,2) must be 1 <=x,y<=scan-width.\n',aname,N);
    return;
  end
  if isfield(ascan{N},'wordtype') & ~isempty(ascan{N}.wordtype),
    switch ascan{N}.wordtype
     case { '_8BIT_UNSGN_INT','_16BIT_SGN_INT','_32BIT_SGN_INT' }
      % looks ok
      fprintf('.wordtype[%s] ',ascan{N}.wordtype);
     otherwise
      fprintf('\nERROR: ASCAN.%s{%d}.wordtype must be _8BIT_UNSGN_INT _16BIT_SGN_INT or_32BIT_SGN_INT.\n',aname,N);
      return;
    end
  end
  fname = sprintf('%d/pdata/%d/2dseq',ascan{N}.scanreco);
  fname = fullfile(SYSP.DataMri,SYSP.dirname,fname);
  if ~exist(fname,'file'),
    fprintf('\nERROR: ''2dseq'' not found/accessible. ''%s''',fname);
    fprintf('\n check ses.DataMri,ses.dirname,ses.%s{%d}.scanreco.\n',...
            aname,N);
    return;
  end
  fname = sprintf('%d/pdata/%d/reco',ascan{N}.scanreco);
  fname = fullfile(SYSP.DataMri,SYSP.dirname,fname);
  if ~exist(fname,'file'),
    fprintf('\nERROR: ''reco'' not found/accessible. ''%s''',fname);
    fprintf('\n check ses.DataMri,ses.dirname,ses.%s{%d}.scanreco.\n',...
            aname,N);
    return;
  end
end
RET = 1;
fprintf(' OK.\n');
return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RET = subCheckRawFile(SYSP,EXPP,ExpNo,ftype)
RET = 0;

switch ftype
 case { 'phys', 'adf', 'adfw' }
  % adf/adfw file
  fname = EXPP(ExpNo).physfile;
  fname = fullfile(SYSP.DataNeuro,SYSP.dirname,fname);
 case { 'phys2', 'adf2', 'adfw2' }
  % adf/adfw file by second streamer
  [n,n1,n2] = fileparts(EXPP(ExpNo).physfile);
  fname = fullfile(SYSP.DataNeuro,SYSP.dirname,sprintf('%s_2%s',n1,n2));
 case { 'vsig', 'video' }
  % video signals
  fname = EXPP(ExpNo).videofile;
  fname = fullfile(SYSP.DataNeuro,SYSP.dirname,fname);
 case { 'evt', 'dgz' }
  % event file
  if isfield(EXPP(ExpNo),'evtfile'),
    fname = EXPP(ExpNo).evtfile;
  else
    [n,n1,n2] = fileparts(EXPP(ExpNo).physfile);
    fname = strcat(n1,'.dgz');
  end
  fname = fullfile(SYSP.DataNeuro,SYSP.dirname,fname);
 case { 'stm', 'pdm', 'hst' }
  % stimulus parameter files
  if isfield(EXPP(ExpNo),'evtfile'),
    [n,n1,n2] = fileparts(EXPP(ExpNo).evtfile);
  else
    [n,n1,n2] = fileparts(EXPP(ExpNo).physfile);
  end
  fname = strcat(n1,'.',ftype);
  fname = fullfile(SYSP.DataNeuro,SYSP.dirname,'stmfiles',fname);  
 case { 'img','2dseq' }
  fname = sprintf('%d/pdata/%d/2dseq', EXPP(ExpNo).scanreco);
  fname = fullfile(SYSP.DataMri,SYSP.dirname,fname);
 case { 'reco' }
  fname = sprintf('%d/pdata/%d/reco', EXPP(ExpNo).scanreco);
  fname = fullfile(SYSP.DataMri,SYSP.dirname,fname);
 case { 'acqp' }
  fname = sprintf('%d/acqp', EXPP(ExpNo).scanreco(1));
  fname = fullfile(SYSP.DataMri,SYSP.dirname,fname);
 otherwise
  fprintf('sescheck.subCheckRawFile: ERROR Wrong file type [phys,evt,img]');
  return;
end
if ~exist(fname,'file'),
  fprintf('\nERROR: file not found/accessible. ''%s''\n',fname);
  return;
end

RET = 1;
return;
