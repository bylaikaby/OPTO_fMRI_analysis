%% orienting images in the same space using SPM
% october 2020 

function mask_norm(rnorm,rtempbi,outputnam)

matlabbatch{1}.spm.util.imcalc.input = {
                                        rnorm
                                        rtempbi
                                        };
matlabbatch{1}.spm.util.imcalc.output = outputnam;
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = 'i2.*i1';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch)

assignin('base','rnormm','rnormm.nii')

end
