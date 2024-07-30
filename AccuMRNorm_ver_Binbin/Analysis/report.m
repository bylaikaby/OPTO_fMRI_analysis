% List of open inputs
% Results Report: Contrast(s) - cfg_entry
% Results Report: Background image - cfg_files
% Results Report: Slices - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'D:\CM032_bids\sub-CM032\first_level_analysis\analysis_scripts\report_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(3, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Results Report: Contrast(s) - cfg_entry
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Results Report: Background image - cfg_files
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % Results Report: Slices - cfg_entry
end
job_id = cfg_util('initjob', jobs);
sts    = cfg_util('filljob', job_id, inputs{:});
if sts
    cfg_util('run', job_id);
end
cfg_util('deljob', job_id);
