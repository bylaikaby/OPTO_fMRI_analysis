% Quality control Q1a
% Check imaging parameters and plot them across all the participants
% Xin Di, July 13, 2022

clear

subjfolder = dir('D:\CM033_bids_new\sub*.');

% Read image information for every participant
for subji = 1:length(subjfolder)
    fprintf('Processing subject %d ...',subji)
    subjfolder_path=fullfile(subjfolder(subji).folder,subjfolder(subji).name);
    v_func = spm_vol([ subjfolder_path, '\func\' subjfolder(subji).name '*.nii']);
    
    n_image(subji,1) = length(v_func);  % number of images
    tr(subji,1) = v_func(1).private.timing.tspace;  % TR
    di = spm_imatrix(v_func(1).mat);
    voxel_func(subji,:) = abs(di(7:9));    % voxel size
    
    v_anat = spm_vol([ subjfolder '\anat\' subjfolder(subji).name '_ses-01_run-01_T1w.nii']);
    
    di = spm_imatrix(v_anat(1).mat);
    voxel_anat(subji,:) = abs(di(7:9));  % voxel size
    

    fprintf('done!\n')
end


% Plot all the parameters across participants
fh = figure('DefaultAxesFontSize',18);
fh.WindowState = 'maximized';

subplot(4,1,1)
bar(n_image)
title('# of fMRI images')
xline([20.5,40.5,56.5,79.5,99.5,119.5]);
xticks([10,30,48,68,89,109,129])
xticklabels({'Rest1','Rest2','Rest3','Rest4','Rest5','Rest6','Rest7'})
box off

subplot(4,1,2)
bar(tr)
title('TR of fMRI images')
xline([20.5,40.5,56.5,79.5,99.5,119.5]);
xticks([10,30,48,68,89,109,129])
xticklabels({'Rest1','Rest2','Rest3','Rest4','Rest5','Rest6','Rest7'})
box off

subplot(4,1,3)
bar(voxel_func)
title('Voxel sizes of fMRI images')
xline([20.5,40.5,56.5,79.5,99.5,119.5]);
xticks([10,30,48,68,89,109,129])
xticklabels({'Rest1','Rest2','Rest3','Rest4','Rest5','Rest6','Rest7'})
box off

subplot(4,1,4)
bar(voxel_anat)
title('Voxel sizes of structrual images')
xline([20.5,40.5,56.5,79.5,99.5,119.5]);
xticks([10,30,48,68,89,109,129])
xticklabels({'Rest1','Rest2','Rest3','Rest4','Rest5','Rest6','Rest7'})
box off

exportgraphics(gcf,['D:\CM033_bids_new\sub-CM033\qc']);

