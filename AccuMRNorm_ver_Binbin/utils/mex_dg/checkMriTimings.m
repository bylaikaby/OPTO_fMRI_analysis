function checkMriTimings(dgzfile)
% PURPOSE : To check timings between mri-triggers and stimuli.
% NOTE :
%
% SEEALSO : dg_read.dll
% VERSION : 0.90  17.10.03  YM
%
global dgz tmri tstm tend sigmri sigstm
  
if nargin == 0,
  help checkMriTimings;
  return
end

dgz = dg_read(dgzfile);
% MRI-EVENT:    E_MRI=46, E_MRI_TRIGGER=0
tmri = subFindEvent(dgz,46,0);
% STIMULUS-ON:  E_STIMULUS=27, S_STIMON=2
%               E_STIMTYPE=29, CurStimulus
tstm = subFindEvent(dgz,29,-1);

fprintf(' DGZFILE : %s\n', dgzfile);
fprintf(' NumTriggs=%d,  NumStim=%d\n',length(tmri),length(tstm));
subDumpEvents(dgz,20);

% make signals
tend = dgz.e_times{1}(end);
sigmri = zeros(1,tend);  sigmri(tmri) = 1;
sigstm = zeros(1,tend);  sigstm(tstm) = 1;

figure;
plot(sigmri,'b');  hold on;
plot(sigstm,'r');  grid on;
set(gca,'xlim',[0 10000],'ylim',[0 1.5]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tevt = subFindEvent(dgz,evttype,subtype)
if subtype == -1,
  idx = find(dgz.e_types{1} == evttype);
else
  idx = find(dgz.e_types{1} == evttype & dgz.e_subtypes{1} == subtype);
end
tevt = dgz.e_times{1}(idx);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subDumpEvents(dgz,nevents)
for N = 1:nevents
  e_time    = dgz.e_times{1}(N);
  e_type    = dgz.e_types{1}(N);
  e_sub     = dgz.e_subtypes{1}(N);
  e_params  = dgz.e_params{1}{N};
  e_nparams = size(e_params,1);
  notes = dgz.e_names(e_type+1, :);
  if e_type == 4,
	if e_params(length(e_params)) == 10,
	  e_params = e_params(1:length(e_params)-1);
	end
	fprintf('\n%3d  %4d %6d   %3d  %3d   %3d  Trace: %s', ...
            N, 1, e_time, e_type, e_sub, e_nparams, e_params);
  else 
	fprintf('\n%3d  %4d %6d   %3d  %3d   %3d  %s', ...
            N, 1, e_time, e_type, e_sub, e_nparams, notes);
  end
end
return;
