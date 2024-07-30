%% binarizing the template using SPM
% october 2024

function binarize_temp_quick(temp,outputnam)

matlabbatch{1}.spm.util.imcalc.input = {temp};
matlabbatch{1}.spm.util.imcalc.output = outputnam;
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i1>0';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm('defaults', 'FMRI');

spm_jobman('run',matlabbatch)


assignin('base','tempbi','tempbi.nii')

end
