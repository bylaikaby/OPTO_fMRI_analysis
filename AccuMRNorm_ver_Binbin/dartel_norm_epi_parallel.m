function dartel_norm_epi_parallel(runs,pathepi,imgtemp,epivox,step, bb, smoothing)
%% Inputs
% runs      = number of runs in this experiment
% pathepi   = path to functional scans
% imgtemp   = deformation (u) file
% epires    = EPI voxel dimensions
% step      = which pass through dartel_norm_epi
% bb        = bounding box (bbox) of fMRI images
%             'individual' uses original bbox via spm_get_bbox()
%             'average'    uses group average of bbox
%             or a [2 3] matrix with the bounding box values

%% Function
imgtemp = fullfile(imgtemp.folder, imgtemp.name);
cd(pathepi);

if ismatrix(bb) & ~isequal(size(bb), [2 3]) %Check bbox matrix dimension
   error('bbox matrix must be of dim [2 3] but was [%s]', num2str(size(bb)))
end

switch step
    case 1
        tic
        fprintf('First Pass of Normalization.\n')
        imgepi = dir('r*.nii');
        epi = cell(1, length(imgepi));
        for i = 1:length(imgepi)
            epi{i} = fullfile(imgepi(i).folder, imgepi(i).name);
        end    
        if isequal(lower(bb), 'average')
            mean_bb = get_mean_bbox(pathepi, 'r');
        end

        % This temporary batch cell array allows parallelization of SPM
        % functions
        tempBatch = cell(1,length(imgepi));

        for  i = 1:length(imgepi)  
            % Normalize to Standard Space
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.template           = {''};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {imgtemp};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images  = {epi(i)};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.vox                = epivox;    
            if isequal(lower(bb), 'individual')
                [bbox, vx] = spm_get_bbox(epi{i});
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = bbox;
            elseif isequal(lower(bb), 'average')
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = mean_bb;    
            elseif ismatrix(bb)
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = bb;
            else % NaNs means the template bbox is used, which is usually very large, leading to enormous file sizes
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = [NaN NaN; NaN NaN; NaN NaN];
            end
    
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.preserve           = 0;
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm               = smoothing; % 0 0 0 
        end
        parfor i = 1:length(imgepi)  
            spm_jobman('run',tempBatch{i}.matlabbatch);
            disp('Done')
        end
           
    case 2
        tic
        % Run on original realigned EPIs
        fprintf('Running second pass at functional scan normalization\n')
        fprintf('----------------------------------------------------\n')
        fprintf('Run on original, realigned EPIs (r*.nii)\n')
        imgepi = dir('r*.nii');
        epi = cell(1, length(imgepi));
        for i = 1:length(imgepi)
            epi{i} = fullfile(imgepi(i).folder, imgepi(i).name);
        end    
        if isequal(lower(bb), 'average')
            mean_bb = get_mean_bbox(pathepi, 'r');
            mean_bb = mean_bb * 1.05;
        end
    
        tempBatch = cell(1,length(imgepi));
        for  i = 1:length(imgepi)  
            % Normalize to Standard Space
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.template           = {''};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {imgtemp};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images  = {epi(i)};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.vox                = epivox;
    
            if isequal(lower(bb), 'individual')
                [bbox, vx] = spm_get_bbox(epi{i});
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = bbox;
            elseif isequal(lower(bb), 'average')
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = mean_bb;    
            elseif ismatrix(bb)
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = bb;
            else % NaNs means the template bbox is used, which is usually very large, leading to enormous file sizes
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = [NaN NaN; NaN NaN; NaN NaN];
            end
    
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.preserve           = 0;
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm               = smoothing; % 0 0 0 
        end
        parfor i = 1:length(imgepi)  
            spm_jobman('run',tempBatch{i}.matlabbatch);
            disp('Done')
        end
    
        clear tempBatch imgepi i
        % Run on previously warped EPIs done with first deformation file
        fprintf('----------------------------------------------------\n')
        fprintf('Run on EPIs warped in the 1st normalization pass (wr*.nii).\n')
        imgepi = dir('wr*.nii');
        epi = cell(1, length(imgepi));
        for i = 1:length(imgepi)
            epi{i} = fullfile(imgepi(i).folder, imgepi(i).name);
        end    
        if isequal(lower(bb), 'average')
            mean_bb = get_mean_bbox(pathepi, 'r');
            mean_bb = mean_bb * 1.05;
        end
    
        tempBatch = cell(1,length(imgepi));
        for  i = 1:length(imgepi)  
            % Normalize to Standard Space
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.template           = {''};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {imgtemp};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images  = {epi(i)};
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.vox                = epivox;
    
            if isequal(lower(bb), 'individual')
                [bbox, vx] = spm_get_bbox(epi{i});
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = bbox;
            elseif isequal(lower(bb), 'average')
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = mean_bb;    
            elseif ismatrix(bb)
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = bb;
            else % NaNs means the template bbox is used, which is usually very large, leading to enormous file sizes
                tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.bb                 = [NaN NaN; NaN NaN; NaN NaN];
            end
    
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.preserve           = 0;
            tempBatch{i}.matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm               = smoothing; % 0 0 0 
        end
        parfor i = 1:length(imgepi)  
            spm_jobman('run',tempBatch{i}.matlabbatch);
            disp('Done')
        end

    otherwise
        error('"%s" is an invalid input.', step)
end   
    
toc
end
