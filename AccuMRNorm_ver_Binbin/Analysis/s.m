% List of open inputs
% Results Report: Select SPM.mat - cfg_files
% Results Report: Contrasts - cfg_repeat
nrun = X; % enter the number of runs here
jobfile = {'D:\CM032_bids\sub-CM032\first_level_analysis\analysis_scripts\s_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Results Report: Select SPM.mat - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Results Report: Contrasts - cfg_repeat
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
