function s = infostim(SESSION,LOG)
%INFOSTIM - Displays the stimulation parameters (visual or electrical)
% INFOSTIM (SESSION,EXPS) displays information regarding the visual, auditory or electrical
% stimulus used in each group.
%
%       expinfo: {'imaging'  'stimulation'  'recording'}
%       stminfo: '0.5mA, 10Hz (4/4/16 sec)x10'
%
% NKL, 10.10.00; 12.04.04, 08.06.09

ESDIR = 'y:\DataMatlab\Microstimulation\';
LIST_TYPE = SESSION;

if nargin < 1 | strcmpi(SESSION,'monkey'),
  ses = rpsessions('monkey','es1','spont');
  for N=1:length(ses),
    grp = getgrp(ses{N},'estim');
    pars = expgetpar(ses{N},grp.exps(1));
    fprintf('Stim-Time: %d %d %d %d (x %d repetitions)\n', pars.stm.dt{1}(1:4),length(pars.stm.v{1})/3);
  end;
  return;
end;

% if nargin < 2,
%   LOG = 0;
% end;

% if nargin < 1,
%   help infostim;
%   return;
% end;

% if LOG,
%   LogFile=strcat(ESDIR,SESSION,'-DFILES','.log');	% Start log file
%   diary off;									% Close previous ones...
%   hbackup(LogFile);								% Make a backup for history
%   diary(LogFile);								% Start the new one
% end;

% switch SESSION,
%  case 'all',
%   lst = es_dfiles('all');
%  case 'anest',
%   lst = es_dfiles('anest');
%  case 'alert',
%   lst = es_dfiles('alert');
%  otherwise,
%   lst{1} = SESSION;
% end;

% try,
%   for N=1:length(lst),
%     SESSION = lst{N};
%     if nargout,
%       s = subINFOSTIM(SESSION);
%     else
%       subINFOSTIM(SESSION);
%     end;
%   end;
% catch,
%   disp(lasterr);
%   keyboard;
% end;

% if LOG,
%   diary off;
%   fprintf('Created LOG File: %s\n', LogFile);
%   fprintf('To edit the file, type: es_editlog('%s')\n', LIST_TYPE);
% end;
% return;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function subINFOSTIM(SESSION)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ses = goto(SESSION);
% grpnames = getgrpnames(Ses);

% for G = 1:length(grpnames),
%   grp = getgrpbyname(Ses,grpnames{G});
%   s{G}.sesname = SESSION;
%   s{G}.grpname = grpnames{G};
%   s{G}.stminfo = grp.stminfo;
% end;

% if ~nargout,
%   for G=1:length(grpnames),
%     fprintf('%s-%s: %s\n', upper(s{G}.sesname), s{G}.grpname, s{G}.stminfo);
%   end;
% end;
% return;
  
