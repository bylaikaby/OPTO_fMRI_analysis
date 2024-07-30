function dartel_norm_epi(runs,pathepi,imgtemp,epivox,step)
%% Inputs
% runs      = number of runs in this experiment
% pathepi   = path to functional scans
% imgtemp   = deformation (u) file
% epires    = EPI voxel dimensions
% step      = which pass through dartel_norm_epi

%% Function
tic
imgtemp = fullfile(imgtemp.folder, imgtemp.name);
cd(pathepi);

if step == 1
    imgepi = dir('r*.nii');
    for i = 1:length(imgepi)
        epi{i} = fullfile(imgepi(i).folder, imgepi(i).name);
        
        % Normalize to Standard Space
        matlabbatch{1}.spm.tools.dartel.mni_norm.template           = {''};
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {imgtemp};
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images  = {epi(i)};
        matlabbatch{1}.spm.tools.dartel.mni_norm.vox                = epivox;
        matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = [NaN NaN; NaN NaN; NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.preserve           = 0;
        matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm               = [0 0 0];
        spm_jobman('run',matlabbatch);
        
        disp('Done')
    end
    
else 
    % Run on original realigned EPIs
   fprintf('Running second pass at functional scan normalization')
    imgepi = dir('r*.nii');
    for i = 1:length(imgepi)
        epi{i} = fullfile(imgepi(i).folder, imgepi(i).name);
        
        % Normalize to Standard Space
        matlabbatch{1}.spm.tools.dartel.mni_norm.template           = {''};
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {imgtemp};
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images  = {epi(i)};
        matlabbatch{1}.spm.tools.dartel.mni_norm.vox                = epivox;
        matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = [NaN NaN; NaN NaN; NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.preserve           = 0;
        matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm               = [2 2 2];
        spm_jobman('run',matlabbatch);
    end
    
    clear matlabbatch imgepi i
    % Run on previously warped EPIs done with first deformation file
    imgepi = dir('wr*.nii');
    for i = 1:length(imgepi)
        epi{i} = fullfile(imgepi(i).folder, imgepi(i).name);
        
        % Normalize to Standard Space
        matlabbatch{1}.spm.tools.dartel.mni_norm.template           = {''};
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {imgtemp};
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images  = {epi(i)};
        matlabbatch{1}.spm.tools.dartel.mni_norm.vox                = epivox;
        matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = [NaN NaN; NaN NaN; NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.preserve           = 0;
        matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm               = [2 2 2];
        spm_jobman('run',matlabbatch);
    end
    disp('Done')
end
toc
end
