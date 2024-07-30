% List of open inputs
% TAPAS PhysIO Toolbox: log_cardiac - cfg_files
% TAPAS PhysIO Toolbox: log_respiration - cfg_files
% fMRI model specification: Name - cfg_entry
% fMRI model specification: Value - cfg_entry
% fMRI model specification: Name - cfg_entry
% fMRI model specification: Value - cfg_entry
nrun = 1; % enter the number of runs here
jobfile = {'D:\CM032_bids\sub-CM032\first_level_analysis\op_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);
for crun = 1:nrun
    inputs{1, crun} = ''; % TAPAS PhysIO Toolbox: log_cardiac - cfg_files
    inputs{2, crun} = ''; % TAPAS PhysIO Toolbox: log_respiration - cfg_files
    inputs{3, crun} = ''; % fMRI model specification: Name - cfg_entry
    inputs{4, crun} = ''; % fMRI model specification: Value - cfg_entry
    inputs{5, crun} = ''; % fMRI model specification: Name - cfg_entry
    inputs{6, crun} = ''; % fMRI model specification: Value - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
