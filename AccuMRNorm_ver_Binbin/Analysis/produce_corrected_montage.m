
function produce_corrected_montage (subject_dirs,fwec,threshold)

    load(fullfile(subject_dirs.analysis_dir,subject_dirs.parameter_file));
    matlabbatch{1}.spm.stats.results.spmmat(1) = cellstr(fullfile(subject_dirs.output_dir,'SPM.mat'));
    matlabbatch{1}.spm.stats.results.conspec.titlestr = subject_dirs.foldername;
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{1}.spm.stats.results.conspec.thresh = threshold;
    matlabbatch{1}.spm.stats.results.conspec.extent = fwec;
    matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 1;
   
    
    matlabbatch{1}.spm.stats.results.export{1}.montage.background = {subject_dirs.print_template};
    matlabbatch{1}.spm.stats.results.export{1}.montage.orientation = 'coronal';
    matlabbatch{1}.spm.stats.results.export{1}.montage.slices = -24:1:28;

   
    spm_jobman('run', matlabbatch(1))
    
    montage_item = findobj('Type', 'figure', '-regexp', 'Name', '.*SliceOverlay.*');
    
    coronal_montage_cor= fullfile(subject_dirs.output_dir,[subject_dirs.foldername,'_CORONAL_FWEc.jpg']);
    sgtitle([subject_dirs.foldername,'_coronal_FWE_corrected']);
    saveas(montage_item, coronal_montage_cor);
    if isfield(subject_dirs,'condition_folder')
        copyfile(coronal_montage_cor,subject_dirs.condition_folder);
    end 
    assignin('base','corrected_coronal_montage',coronal_montage_cor)

end