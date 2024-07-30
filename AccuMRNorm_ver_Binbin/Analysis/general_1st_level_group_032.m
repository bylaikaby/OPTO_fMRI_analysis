%-----------------------------------------------------------------------
% Job saved on 03-Mar-2024 16:06:44 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%% 

% Define the base directory and subject ID
baseDir = 'D:\\CM032_bids';
subjectID = 'sub-CM032';
taskName = ["OPTO","MSTIM","OPTO+MSTIM"];
analysis_dir=fullfile(baseDir,subjectID,'first_level_analysis');
conditions = ["BLANK_pre","STIM","BLANK_post"]; % conditions in order


%tasks for this model
taskChosen=taskName{3};




% in order to identify the potential confounding effect of visual
% activation, first separate the runs 

runIds=[12,15,17,18,20,22:28,32,33,38:41,47:50];

%ids for the OPTO Runs
optoIds=[12,15,17,18,20,22:28,32,33];


%ids for the MSTIM Runs
mstimIds=[38:41,47:50,42:44];

%ids for this model
groupIds=[12,15,17,18];

% potential group 2
% groupIds=[20,22:28,32:33];


% scanIDs = [1:10];
onsetTimesDir = fullfile(baseDir, subjectID, 'first_level_analysis','onset_times'); % Directory containing onset times

% Get the current date and time
currentDateTime = datetime('now');

% Format the date and time into a string that can be used as a folder name
% For example: '2023-03-29_15-45-30'
folderName = sprintf('%s_1stLevel_output_%s',taskChosen,datestr(currentDateTime, 'mm-dd_HH-MM'));

%% 

cd(analysis_dir);            
mkdir(folderName);
cd(folderName);

matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(analysis_dir,folderName)};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 18;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 6;
%% 

% Loop over sessions (runs)
for iRun = 1:length(groupIds)
    scans = {};
    
    
    if ismember(groupIds(iRun),optoIds)
        scanIndex=find(optoIds==groupIds(iRun));
        scanFileName = sprintf('r%s_task-%s_run-%02d_EPI.nii', subjectID, taskName{1}, scanIndex+2);
    elseif ismember(groupIds(iRun),mstimIds)
        scanIndex=find(mstimIds==groupIds(iRun));
        scanFileName = sprintf('r%s_task-%s_run-%02d_EPI.nii', subjectID, taskName{2}, scanIndex);
    end

     % Initialize the scans list for the current session
    
   
    scanFile = fullfile(analysis_dir, 'func', scanFileName);
    regressor_file = sprintf('tissue_regressors_%s.txt',scanFileName);
    matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).multi_reg={fullfile(analysis_dir, 'func', regressor_file)};

    vol_num = length(spm_vol(scanFile));  % Try to read the file

    % If an error occurs, log it and try with taskName{2}
     
 
    % Construct file paths for all scans in the current run
    for vol = 1:vol_num 
        frameFile = [scanFile,',',num2str(vol)];
%         change here to modify the data taking path
        scans{end+1} = frameFile;  % Add to scans list
    end
    
    % Assign scans to the current session in the batch
    matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = cellstr(scans');


    % access the raw IDs of each run based on runIDs
    run_number_seq=1:length(runIds);
    runIndex =run_number_seq(runIds==groupIds(iRun)); 
    % Loop over conditions to assign condition names, onset times, and durations
    for iCond = 1:length(conditions)
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).orth = 1;
       
        condName = string(conditions{iCond});   
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).name = char(condName);
       
       % Construct the filenames for onset times and durations
        onsetFileName = fullfile(onsetTimesDir, sprintf('%03d_%s_onset_times.txt',runIds(runIndex) , condName));

        durationFileName = fullfile(onsetTimesDir, sprintf('%03d_all_durations.txt',runIds(runIndex)));

        
        
%         if exist('duration','var')==1
%             if duration == 0||18
%                 matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).duration = duration;
%             end
%         else
%                 durations = load(durationFileName);
%                 matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).duration = durations;
% 
%         end

        % Check if the onset time and duration files exist
        if exist(onsetFileName, 'file') 
            % Load onset times and durations from the files
            onsetTimes = load(onsetFileName);
            
            % Assign condition names, onset times, and durations to the current session
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).onset = onsetTimes;
        else
    % Display an error message
        error('File not found: %s', onsetFileName);   
        end

        if exist(durationFileName,'file')
            all_durations = load(durationFileName);

            durations = all_durations(:,iCond);

            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).duration = durations;
        else
    % Display an error message
             warning('File not found: %s', onsetFileName);     
        
            if condName == 'STIM'
            duration= 12 ;
            
            elseif condName == 'BLANK_pre'
            duration= 4 ;
            elseif condName =='BLANK_post'
            duration = 28;
        
            % If there are other fields like parametric modulations (pmod), include them here
     
     
            end
        end
end
end
matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile(analysis_dir,folderName)};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 18;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 6;

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {'D:\CM032_bids\sub-CM032\first_level_analysis\new_cm032_mask.nii'};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';


%% 

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

cd(analysis_dir)