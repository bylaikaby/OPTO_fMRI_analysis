function tpm=seg_ana(par)
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
Img2seg = par.ana;                             % native anatomical after mancoreg

files = dir(par.temp_dir);

% Initialize the tpm cell array
tpm = {};

% Loop through the files and find those containing 'csf', 'gm', or 'wm' (case insensitive)
for i = 1:length(files)
    filename = files(i).name;
    
    if contains(lower(filename), 'csf') || contains(lower(filename), 'gm') || contains(lower(filename), 'wm')
        tpm{end+1} = fullfile(par.temp_dir, filename);
    end
end

matlabbatch{1}.spm.tools.oldseg.data            = {Img2seg};
matlabbatch{1}.spm.tools.oldseg.output.GM       = [1 1 1];
matlabbatch{1}.spm.tools.oldseg.output.WM       = [1 1 1];
matlabbatch{1}.spm.tools.oldseg.output.CSF      = [1 1 1];
matlabbatch{1}.spm.tools.oldseg.output.biascor  = 1;
matlabbatch{1}.spm.tools.oldseg.output.cleanup  = 1;
matlabbatch{1}.spm.tools.oldseg.opts.tpm        = tpm';
matlabbatch{1}.spm.tools.oldseg.opts.ngaus      = [2 2 2 4];
matlabbatch{1}.spm.tools.oldseg.opts.regtype    = 'rigid'; % cleans up warp and more translation
matlabbatch{1}.spm.tools.oldseg.opts.warpreg    = 1;
matlabbatch{1}.spm.tools.oldseg.opts.warpco     = 21.5;
matlabbatch{1}.spm.tools.oldseg.opts.biasreg    = 1;
matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm   = 60;
matlabbatch{1}.spm.tools.oldseg.opts.samp       = 2.50;
matlabbatch{1}.spm.tools.oldseg.opts.msk        = {''}; 

% Begin Initial Import
matlabbatch{2}.spm.tools.dartel.initial.matnames(1) = cfg_dep('Pre-proc: Old segment: Norm Params Subj->MNI', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','snfile', '()',{':'}));
matlabbatch{2}.spm.tools.dartel.initial.odir    = {par.norm_dir};
matlabbatch{2}.spm.tools.dartel.initial.bb      = [NaN NaN; NaN NaN; NaN NaN];
matlabbatch{2}.spm.tools.dartel.initial.vox     = Inf;                      % Vox size of resulting norm img will match template mask vox res

% Img out bias corr & skull-stripped(choose 3 for biased corr img)
matlabbatch{2}.spm.tools.dartel.initial.image   = 3;
matlabbatch{2}.spm.tools.dartel.initial.GM      = 1;
matlabbatch{2}.spm.tools.dartel.initial.WM      = 1;
matlabbatch{2}.spm.tools.dartel.initial.CSF     = 1;



matlabbatch{3}.spm.spatial.coreg.write.ref = {par.temp_fulldir};

warpedimg   = cellstr(strcat(par.norm_dir,'\rc2', par.anaorig));          % warped img. native after warping to templ
rimgana     = cellstr(strcat(par.norm_dir,'\r', par.anaorig));            % realigned anatomicals

matlabbatch{3}.spm.spatial.coreg.write.source= [rimgana,warpedimg]';
matlabbatch{3}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{3}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{3}.spm.spatial.coreg.write.roptions.prefix = 'r';



% Run job in SPM
spm_jobman('run',matlabbatch);
clear matlabbatch

toc

disp('Done')

end
