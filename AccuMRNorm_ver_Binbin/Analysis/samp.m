% List of open inputs
% Contrast Manager: Select SPM.mat - cfg_files
% Contrast Manager: Name - cfg_entry
% Contrast Manager: Name - cfg_entry
% Contrast Manager: T contrast for extra regressors - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'D:\CM032_bids\sub-CM032\first_level_analysis\analysis_scripts\samp_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Contrast Manager: Select SPM.mat - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Contrast Manager: Name - cfg_entry
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Contrast Manager: Name - cfg_entry
    inputs{4, crun} = MATLAB_CODE_TO_FILL_INPUT; % Contrast Manager: T contrast for extra regressors - cfg_entry
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
