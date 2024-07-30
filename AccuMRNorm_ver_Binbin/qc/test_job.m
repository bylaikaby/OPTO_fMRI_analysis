%% setup par
cd (cwd);

% save all the path and name sinformation to a structure 'par'.

par = parget(subject_name,cwd,AccuMRNorm_Dir,temp_Dir,temp)


%% QC for general info
inspect_scansinfo (par);
%% QC for motion
motion_par(par)

%% Pre-Module: Re-Orientation
% cd (par.pathepi)
% 
% for i = 1:numel(par.runs)
%  epi = par.runs(i).name;
%  setNiiOrientation (epi);
% %  flip_lr(epi,epi)
% 
% end
% 
% anas=dir(fullfile(par.pathana,"*.nii"));
% 
% for i = 1:length(anas)
%  ana = fullfile(anas(i).folder,anas(i).name);
%  setNiiOrientation (ana);
% %  flip_lr(ana,ana)
% %
% 
% end
% cd(cwd)
%% realign the three opto sessions
folders = {par.runs.name}; % Use the name field of par.runs to get the file paths
folders = folders';
for i = 1:numel(folders)
    folders{i} = fullfile(par.runs(i).folder,folders{i}); 
    folders{i} = cellstr(folders{i});
end

% Anatomical Scan

matlabbatch{1}.spm.spatial.realign.estwrite.data = folders(31:33);
                                                    
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'q';


spm_jobman('run', matlabbatch(1));


%% skull strip to improve segmentation and normalisation


% Use bet4animal (brain extraction tool of FSL) to skullstripp the anatomical image chosen
% 0.2 is the threshold to use for bet

run_bet4animal_macaque('/home/bb/fsl',par.ana,par.pathana,0.26);


% Inpect the result of skull stripping
spm_check_registration (par.ana,ss_anat,par.temp_fulldir);
spm_orthviews('Reposition', 64.5, 64.5, 20.0);
spm_orthviews('Zoom', -inf, 3);

userInput = input('Skull-stripping Alright? (Y/N): ', 's');

% Check the user's input
if strcmpi(userInput, 'Y')
    disp('skull stripped ana is now the main ana');
    % Add your code for the next steps here
    par.ana=ss_anat;
    [~,par.anaorig,~]=fileparts(ss_anat);
    par
elseif strcmpi(userInput, 'N')
    disp('redo the skull stripping');
    return;  % or add code to handle the exit
else
    disp('Invalid input. ');
    % Handle the case where the input is neither Y nor N
end
%%
matlabbatch{2}.spm.spatial.coreg.estwrite.ref ={fullfile(par.pathepi,'meansub-CM033_task-OPTO_run-01_EPI.nii')};
matlabbatch{2}.spm.spatial.coreg.estwrite.source = cellstr(par.ana);
matlabbatch{2}.spm.spatial.coreg.estwrite.other = {'large_mask.nii'};
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [5 5];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 7;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [1 1 1];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'c';


spm_jobman('run', matlabbatch(2));


par.ana=fullfile(par.pathana,['c',par.anaorig]);

%% QC

qcDisplay(par,4);



%% manocoreg the ana and 
mancoregvar=mancoreg(par.temp_fulldir,par.ana);

norm_epi(par.folder,mancoregvar,par.runs(31:33),par.norm_dir);
%% segmentation to create ROI files. Then create binary mask
segmentation_NMT(par.ana,par.temp_dir,par.norm_dir);  
par.mask=binary_mask(par.ana,'anamask',par.pathana);

% Note, at this stage, might need to use 

%% smooth

matlabbatch{1}.spm.spatial.smooth.data = '<UNDEFINED>';
matlabbatch{1}.spm.spatial.smooth.fwhm = [2 2 2];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';


