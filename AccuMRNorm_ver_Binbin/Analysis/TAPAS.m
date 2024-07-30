% List of open inputs
% TAPAS PhysIO Toolbox: log_cardiac - cfg_files
% TAPAS PhysIO Toolbox: log_respiration - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'D:\CM032_bids\sub-CM032\first_level_analysis\TAPAS_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % TAPAS PhysIO Toolbox: log_cardiac - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % TAPAS PhysIO Toolbox: log_respiration - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
