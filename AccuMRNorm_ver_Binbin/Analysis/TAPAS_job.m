%-----------------------------------------------------------------------
% Job saved on 18-Apr-2024 10:10:04 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.physio.save_dir = {''};
matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Philips';
matlabbatch{1}.spm.tools.physio.log_files.cardiac = '<UNDEFINED>';
matlabbatch{1}.spm.tools.physio.log_files.respiration = '<UNDEFINED>';
matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {''};
matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'last';
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = 123;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = 1;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 123;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = 123;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 21;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = 12;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = 213;
matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'ECG';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.no = struct([]);
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
matlabbatch{1}.spm.tools.physio.preproc.respiratory.filter.passband = [0.01 2];
matlabbatch{1}.spm.tools.physio.preproc.respiratory.despike = false;
matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.c = 3;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.r = 4;
matlabbatch{1}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
%%
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.fmri_files = {
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-01_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-01_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-02_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-03_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-04_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-05_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-06_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-07_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-08_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-09_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-10_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-11_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-12_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-MSTIM_run-13_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-01_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-02_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-03_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-04_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-05_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-06_EPI.nii'
                                                                   'D:\CM032_bids\sub-CM032\first_level_analysis\func\rsub-CM032_task-OPTO_run-07_EPI.nii'
                                                                   };
%%
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.roi_files = {''};
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.force_coregister = 'Yes';
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.thresholds = 0.9;
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_voxel_crop = 0;
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_components = 1;
matlabbatch{1}.spm.tools.physio.model.movement.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
matlabbatch{1}.spm.tools.physio.verbose.level = 2;
matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = '';
matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
