function mask=binary_mask(input_img,output_name,output_dir)

 % Set default values for output_name and output_dir
    if nargin < 2 || isempty(output_name)
        output_name = 'mask';
    end
    if nargin < 3 || isempty(output_dir)
        output_dir = pwd; % Use current directory if output_dir is not provided
    end

    matlabbatch{1}.spm.util.imcalc.input = {input_img};
    matlabbatch{1}.spm.util.imcalc.output = output_name;
    matlabbatch{1}.spm.util.imcalc.outdir = {output_dir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1>0.99';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

    spm('defaults', 'FMRI');

    spm_jobman('run',matlabbatch);

    mask=fullfile(output_dir,[output_name,'.nii']);
