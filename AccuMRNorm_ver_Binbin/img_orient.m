%% orienting images in the same space using SPM
% october 2020 

function img_orient(tempbi,norm, rnorm)

matlabbatch{1}.spm.spatial.realign.write.data = {
                                                 tempbi
                                                 norm
                                                 };
matlabbatch{1}.spm.spatial.realign.write.roptions.which = [2 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.write.roptions.prefix = 'r';


spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch)

assignin('base','rtempbi','rtempbi.nii')

end

