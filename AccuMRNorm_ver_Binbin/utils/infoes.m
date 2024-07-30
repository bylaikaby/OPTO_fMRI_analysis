function esinfo = infoes(SesName,EXPS)
%INFOES - Return information on ES-Physiology Sessions
%  INFOES(SESSION,EXPS) returns all infor about electrical stimulation
%
%  VERSION :
%    NKL 12.08.2006
%    YM  10.10.2006  supports grp.esartwin/esspkwin as artifact window
%    YM  13.10.2006  supports grp.visref as reference timing for visual trials
%
%  See also SESESMEAN

if nargin == 0,  eval(sprintf('help %s',mfilename)); return;  end

Ses = goto(SesName);
anap = getanap(Ses);

if ~exist('EXPS','var') | isempty(EXPS),
  EXPS = validexps(Ses);
end
% EXPS as a group name or a cell array of group names.
if ~isnumeric(EXPS),  EXPS = getexps(Ses,EXPS);  end

grp = getgrp(Ses,EXPS);

if ischar(EXPS),
  ExpNo = grp.exps(1);
else
  ExpNo = EXPS(1);
end;

esinfo = {};

if ~isrecording(Ses,ExpNo) | ~ismicrostimulation(Ses,ExpNo),
  fprintf('INFOES: This is not a ES-PHYS session!\n');
  return;
end

try,
  pulseW = sum(grp.espdur)/1000;
  esinfo.session = SesName;
  esinfo.name    = grp.name;
  esinfo.expno   = ExpNo;
  esinfo.esch    = grp.esch;
  esinfo.stminfo = grp.stminfo;
  if grp.espdur(1) & grp.espdur(3),                  
    esinfo.estype  = 'biphasic';
  else
    esinfo.estype  = 'monopulse';
  end;
  if grp.espcur(1) < 0,
    esinfo.eslead = 'cathodal';
  else
    esinfo.eslead = 'anodal';
  end;
  esinfo.espdur1 = grp.espdur(1);
  esinfo.espgap  = grp.espdur(2);
  esinfo.espdur2 = grp.espdur(3);
  esinfo.espwidth= sum(grp.espdur);
  
  if isfield(grp,'esartwin') & ~isempty(grp.esartwin),
    esinfo.artwin = grp.esartwin;
  else
    esinfo.artwin = [-esinfo.espdur1/2 esinfo.espwidth+esinfo.espdur1];
  end
  if isfield(grp,'esspkwin') & ~isempty(grp.esspkwin),
    esinfo.spkwin = grp.esspkwin;
  else
    esinfo.spkwin = [];
  end
  if isfield(grp,'esvisref') & ~isempty(grp.esvisref),
    esinfo.visref = grp.esvisref;
  else
    esinfo.visref = '';
  end
  

  esinfo.esppeak = abs(grp.espcur(1))+abs(grp.espcur(3));
  esinfo.esfreq = grp.esfreq;
  esinfo.labels  = {'Session';'Group';'ExpNo'; 'ES Chan';'Gen Info';'ES Type';'Leading';...
                   'Lead Dur (ms)'; 'Gap (ms)'; 'Follow Dur (ms)'; 'ES Width (ms)'; 'ArtRem Win (ms)'; ...
                    'P-P Cur (uA)'; 'ES Freq (Hz)'};

  if ~nargout,
    names = fieldnames(esinfo);
    for N=1:length(names)-1,
      vals = getfield(esinfo,names{N});
      if ischar(vals),
        fprintf('%18s: %s\n', esinfo.labels{N}, vals);
      else
        if length(vals)>1,
          fprintf('%18s: %4.2f %4.2f\n', esinfo.labels{N}, double(vals));
        else
          fprintf('%18s: %4.2f\n', esinfo.labels{N}, double(vals));
        end;
      end;      
    end;
  end;
  
catch,
  disp(lasterr);
  fprintf('\nINFOES: Check description file\n');
  return;
end;
return

