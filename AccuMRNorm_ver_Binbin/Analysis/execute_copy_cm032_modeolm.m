

clear all
jobfile = {'D:\CM032_bids\sub-CM032\first_level_analysis\Copy_of_general_1st_level_group_032.m'};
spm('defaults', 'FMRI');
spm_jobman('run', jobfile);