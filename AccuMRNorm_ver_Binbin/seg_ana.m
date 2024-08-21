function seg_ana(ana,tempdir,normdir)
%% Inputs
% path      = relevant path directory.
% fnameana  = name of the relevant anatomy file.
% datapath  = path to data.
% folder    = working folder per experiment.
% tempdir   = direcotry with template files.
% normdir   = direcotry with normalized volume and tform .mat files.

%% Function
% segment anatomy
tic
Img2seg = ana;                             % native anatomical after mancoreg


matlabbatch{1}.spm.tools.oldseg.data            = {Img2seg};
matlabbatch{1}.spm.tools.oldseg.output.GM       = [1 1 1];
matlabbatch{1}.spm.tools.oldseg.output.WM       = [1 1 1];
matlabbatch{1}.spm.tools.oldseg.output.CSF      = [1 1 1];
matlabbatch{1}.spm.tools.oldseg.output.biascor  = 1;
matlabbatch{1}.spm.tools.oldseg.output.cleanup  = 1;
matlabbatch{1}.spm.tools.oldseg.opts.tpm        = {
    strcat(tempdir, '/CMT_csf.nii')                                          
    strcat(tempdir, '/CMT_gm.nii')                                          
    strcat(tempdir, '/CMT_wm.nii')                                        
    };
matlabbatch{1}.spm.tools.oldseg.opts.ngaus      = [2 2 2 4];
matlabbatch{1}.spm.tools.oldseg.opts.regtype    = 'rigid'; % cleans up warp and more translation
matlabbatch{1}.spm.tools.oldseg.opts.warpreg    = 1;
matlabbatch{1}.spm.tools.oldseg.opts.warpco     = 21.5;
matlabbatch{1}.spm.tools.oldseg.opts.biasreg    = 1;
matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm   = 60;
matlabbatch{1}.spm.tools.oldseg.opts.samp       = 2.58;
matlabbatch{1}.spm.tools.oldseg.opts.msk        = {''}; 

% Begin Initial Import
matlabbatch{2}.spm.tools.dartel.initial.matnames(1) = cfg_dep('Pre-proc: Old segment: Norm Params Subj->MNI', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','snfile', '()',{':'}));
matlabbatch{2}.spm.tools.dartel.initial.odir    = {normdir};
matlabbatch{2}.spm.tools.dartel.initial.bb      = [NaN NaN; NaN NaN; NaN NaN];
matlabbatch{2}.spm.tools.dartel.initial.vox     = Inf;                      % Vox size of resulting norm img will match template mask vox res

% Img out bias corr & skull-stripped(choose 3 for biased corr img)
matlabbatch{2}.spm.tools.dartel.initial.image   = 3;
matlabbatch{2}.spm.tools.dartel.initial.GM      = 1;
matlabbatch{2}.spm.tools.dartel.initial.WM      = 1;
matlabbatch{2}.spm.tools.dartel.initial.CSF     = 1;

% Run job in SPM
spm_jobman('run',matlabbatch);
clear matlabbatch

toc

disp('Done')

end
