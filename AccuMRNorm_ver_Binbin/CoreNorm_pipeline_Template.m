% 

% Working Normalisation pipeline used by Binbin

% it requires several customised functions:

% Any questions please contact me at binbin.yan@icpbr.ac.cn



% Latest Pipeline:
% Need to add: Bias field correction via segmentation


% To improve:

% Add more check_reg QCs.
% Add evaluation module.


%% Pre-Module: BIDS format conversion 

% Uses BRKRAW to perform the conversion.
% BRKRAW requires linux, thus called wsl commands. Note, the conversion had
% issue with latest version of BRKRAW, so instead used a older version
% (0.3.7)

clear all

root_directory = 'D:\OPTO_fMRI_CM\';
orig_dataset2convert = 'D:\OPTO_fMRI_CM\Raw_data\CM032.Aw1';
[data_dir,orig_dataset_name,ext] = fileparts(orig_dataset2convert);
bids_name = [orig_dataset_name,'_','BIDS'];
bids_directory = [root_directory,'/BIDS_data'];

subject_name = ['sub-',orig_dataset_name];
AccuMRNorm_Dir = 'D:\OPTO_fMRI_CM\code';

% automatic add_path to include the dependent toolboxes
addpath(genpath(AccuMRNorm_Dir));

temp_Dir = 'D:\OPTO_fMRI_CM\Templates\CMT'; % Folder of the template
temp = 'CMT'; % Default template file name

% % Adding additional dependencies
% folders = {'exppar','mri','plt','utils','linux','nifti_tools-master','paravision','stat'};
% sub_Dirs = cellfun(@(folder) fullfile(AccuMRNorm_Dir, folder), folders, 'UniformOutput', false);
% addpath(AccuMRNorm_Dir);
% cellfun(@(sub_Dir) addpath(genpath(sub_Dir)),sub_Dirs);

%% BRKRAW BIDS Table-Creation 

% IMPORTANT
% Created Table is incomplete
% We need to update information in the .xlsx table created, to
% fill in information like task type, run number, so that we can
% distinguish them after conversion.

cd (data_dir)
bids_help_cmd = ['wsl /home/bb/miniconda3/bin/brkraw bids_helper ' ...,
    [orig_dataset_name,ext,' ',orig_dataset_name,' -f xlsx -j']];

system (bids_help_cmd)
%% BRKRAW BIDS Conversion and .gz file unzipping 
bids_convert_cmd = ['wsl /home/bb/miniconda3/envs/unet/bin/brkraw bids_convert ',[orig_dataset_name,ext,' ',orig_dataset_name,'.xlsx -j ',orig_dataset_name,' -o ../BIDS_data/',bids_name]] ;

system (bids_convert_cmd)
cd (bids_directory);
% decompress the converted dataset to allow processing with SPM.
system(['wsl gunzip -r ',bids_name])


%% Directory and Filename Parsing

cd (fullfile (bids_directory,bids_name));
subject_directory = pwd;

% save all the path and name information to a structure 'par'.

par = parget(subject_name,subject_directory,AccuMRNorm_Dir,temp_Dir,temp);


 


%% Re-Orientation
cd (par.pathepi)

for i = 1:numel(par.runs)
 epi = par.runs(i).name;
 setNiiOrientation (epi);
end

anas=dir(fullfile(par.pathana,"*.nii"));

for i = 1:length(anas)
 ana = fullfile(anas(i).folder,anas(i).name);
 setNiiOrientation (ana);
%  flip_lr(ana,ana)
end
%% Quality Check #1, pre-normalisation

% Inspection of the dimensions of the EPIs.

par = inspect_scansinfo (par);

% Inspection of alignment between ANA, EPI (samples) and TEMP (NMT)
qcDisplay(par,4);



%% Normalisation Module: Skull Stripping


% Use bet4animal (brain extraction tool of FSL) to skullstripp the anatomical image chosen
% 0.2 is the threshold to use for bet

run_bet4animal_macaque('/home/bb/fsl',par.ana,par.pathana,0.2);


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
    disp('Redo the skull stripping');
    return;  % or add code to handle the exit
else
    disp('Invalid input. ');
    % Handle the case where the input is neither Y nor N
end

% save 'par' for ease of reloading

save(fullfile(par.work_dir,"par.mat"),"par")
%% Normalisation Module: Reslicing (EPI2EPI) and Realignment (ANA2EPI)

% note: here I am testing the normalisation, hence creating some additional
% pars to store the partial runs.

fMRI_preprocessing_par(par);


% motion_par (par)
        

%% Normalisation Module: Quality Check of the RR process

qcDisplay(par,3,'r');


%% Normalisation Module: Manual Coregistration 

% note, do not close the panel after finishing the adjustment. As the
% followup EPI coregistration will require transformation information from
% it.

[mancoregvar] = mancoreg(par.temp_fulldir,par.ana);       
                                                                 
% realign the EPIs 
% note here par.runs is used instead of par.runs, norm_epi
% automatically choose to normalise functionals with prefix r, meaning
% resliced
norm_epi(par.folder,mancoregvar,par.runs,par.norm_dir);



%% Normalisation Module: DARTEL Prep
%% - DARTEL Prep 1: get epivox, parameter adaptations
% check epi vox dimension
niftiinfo(fullfile(par.runs(1).folder,par.runs(1).name)).PixelDimensions
epivox =[0.75,0.72,2];

USE_PARALLEL= true ; % true:  parallelization to process functional scans
                     % false: uses usual serial processing
% Settings for DARTEL transform of functional scans    
smoothing1  = [0 0 0]; % FWHM: Smoothing for 1st pass

smoothing2  = [2 2 2]; % FWHM: Smoothing for 2nd pass
bounding_box = [-50 -38.7 -5.9; 50 64.3 46.1];          

%% - DARTEL Prep 2: Tissue Probability Maps 
% 4) Generation of probability maps (through segmentation of anatomical data 
% (seg_ana)) and subsequent skull stripping (skullstrip).
%%
% probability maps for anatomy
seg_ana(par.ana,par.temp_dir,par.norm_dir);  

% % avg pob maps & skull strip
% skullstrip(par.pathana,par.anaorig);                             
% 
% % re-run segmentation to get skullstripped prob maps
% fnameana    = strcat('ss',par.anaorig);                                     % specify parameter
% 
% seg_ana(par.pathana,fnameana,subject_directory,par.folder,par.temp_dir,par.norm_dir);
%% Normalisation Module: DARTEL 

%% - DARTEL Normalisation (Anatomical): 1st Pass
% 5) Use DARTEL algorithm to normalize the anatomical data (dartel_norm_ana).

warpedimg   = cellstr(strcat(par.norm_dir,'\rc2', par.anaorig));          % warped img. native after warping to templ
rimgana     = cellstr(strcat(par.norm_dir,'\r', par.anaorig));            % realigned anatomicals

c3Images    = cellstr(strcat(par.pathana,'\c3',par.anaorig));             % c3-segmented img (WM)
c2Images    = cellstr(strcat(par.pathana,'\c2',par.anaorig));             % c2-segmented img (GM)
c1Images    = cellstr(strcat(par.pathana,'\c1',par.anaorig));             % c1-segmented img (CSF)

dartel_norm_ana(warpedimg,rimgana,c3Images, c2Images,c1Images);
%% QC on the first ANA Normalisation
% Convert cell array to character array for spm_check_registration
allImages = [warpedimg; rimgana; c3Images; c2Images; c1Images];

filepaths = char(allImages);
[~, image_names, ~] = cellfun(@fileparts, allImages, 'UniformOutput', false);

% Display all anatomical files using spm_check_registration
spm_check_registration(filepaths,par.temp_fulldir);

spm_orthviews('Caption', image_names);
%% - DARTEL Normalisation (Functional): 1st Pass
cd(par.norm_dir)
imgtemp     = dir (['u_rc2',par.baseFileNameNoExt,'_Template.nii']); % specify deformation file 

% first pass at EPI warping
switch USE_PARALLEL
    case true  % If we run parallelized mode
        dartel_norm_epi_parallel(par.runs,par.pathepi,imgtemp,epivox,1, bounding_box, smoothing1); 
    case false % If we run regular mode
        dartel_norm_epi(par.runs,par.pathepi,imgtemp,epivox,1);
end         
%% QC on the first EPI Normalisation
qcDisplay(par,3,'wr');

%% DARTEL Normalisation: Manual Coregistration, Refinement of Normalization Parameters
%% part1: Quality check & manual adaptations (mreg2d_gui)

fnameana    = strcat('wr',par.anaorig);                                   % specify parameter
ana         = fullfile(par.norm_dir,fnameana);                              % specify parameter
%GUI for manual adaptations
mreg2d_gui(par.temp_fulldir,ana);        

%% part2: Export of the results to .nii files (tvol2nii).  

tvol2nii(par.norm_dir, par.temp_dir, par.temp); 

%%
fnameana = strcat('wrss',par.baseFileNameNoExt,'_ref(',par.temp,')_mreg2d_volume.nii'); 
seg_ana(par.norm_dir,fnameana,subject_directory,par.folder,par.temp_dir,par.norm_dir);

warpedimg   = cellstr(strcat(par.norm_dir,'\rc2',fnameana));
rimgana     = cellstr(strcat(par.norm_dir,'\r', fnameana));
c3Images    = cellstr(strcat(par.norm_dir,'\c3',fnameana));
c2Images    = cellstr(strcat(par.norm_dir,'\c2',fnameana));
c1Images    = cellstr(strcat(par.norm_dir,'\c1',fnameana));

dartel_norm_ana(warpedimg,rimgana,c3Images, c2Images,c1Images);allImages = [warpedimg; rimgana; c3Images; c2Images; c1Images];
    

%%
cd(par.norm_dir)
imgtemp     = dir('u_rc2wrss*.nii'); 					            % specify deformation file 

% second pass at EPI warping
switch USE_PARALLEL
    case true  % If we run parallelized mode
        dartel_norm_epi_parallel(par.runs,par.pathepi,imgtemp,epivox,2, bounding_box, smoothing2); 
    case false % If we run regular mode
        dartel_norm_epi(par.runs,par.pathepi,imgtemp,epivox,2);
end