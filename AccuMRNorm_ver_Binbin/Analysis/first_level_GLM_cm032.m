

%% 
clear all
warning('off', 'MATLAB:MKDIR:DirectoryExists');

% Define the base directory and subject ID
baseDir = 'D:\\CM032_bids_NEW';
subjectID = 'sub-CM032';

% Define the output folder 
analysis_folder_name = 'first_level_analysis';

% Define the task modeled
taskName= ["OPTO","MSTIM","OPTO+MSTIM"];
taskName=taskName(3);


% Define structural regressor ROI files
% regressor_rois={'D:\CM032_bids\sub-CM032\first_level_analysis\warped_temps\resampled_warped_TPM_CSF.nii',...
%     'D:\CM032_bids\sub-CM032\first_level_analysis\warped_temps\resampled_warped_TPM_WM.nii'};
regressor_rois= {'D:\CM032_bids_NEW\sub-CM032\first_level_analysis\func\c1meansub-CM032_task-MSTIM_run-01_EPI_BETss.nii'
'D:\CM032_bids_NEW\sub-CM032\first_level_analysis\func\c3meansub-CM032_task-MSTIM_run-01_EPI_BETss.nii'};

% Deine Mask                                                                  
GLM_mask_file='D:\CM032_bids_NEW\sub-CM032\first_level_analysis\func\meansub-CM032_task-MSTIM_run-01_EPI_BETss.nii';                                   

% Define the data structure for OPTO and MSTIM groups
IDs = struct();

% Adding OPTO IDs
IDs.OPTO.Pos1 = [12, 15, 17, 18];
IDs.OPTO.Pos2 = [20, 22:28];
IDs.OPTO.Pos3 = [32, 33];
% IDs.OPTO.Combined = [IDs.OPTO.Pos1,IDs.OPTO.Pos2];
% Adding MSTIM IDs
IDs.MSTIM.Pos1 = 38:41;
IDs.MSTIM.Pos2 = 47:50;
IDs.MSTIM.Pos3 = 42:44;
IDs.MSTIM.Pos4 = 55:56 ;
IDs.MSTIM.Combined= [IDs.MSTIM.Pos1,IDs.MSTIM.Pos2,IDs.MSTIM.Pos3,IDs.MSTIM.Pos4];




% specifying the threshold for results display
threshold = 0.05;

% save those parameters which are less likely to change by iterations

paramfile_name="base_1st_GLM_parameters.mat";
paramfile=fullfile(baseDir, subjectID, analysis_folder_name,paramfile_name);
save(paramfile)

% paramfile = fullfile(pwd,paramfile_name);

% run settting when not using comparison mode
conditions = ["BLANK_pre","STIM","BLANK_post"] ; % conditions in order, choose from "BLANK_pre","STIM","BLANK_post"
position = 'Pos2';

subject_dirs=setup_GLM_directories(position,conditions,paramfile);

subject_idinfo = construct_idinfo (subjectID,IDs,taskName,position);

cd(subject_dirs.analysis_dir)


comparison_mode=true;
comparison_folder = sprintf("%s_model_comparison_smoothed_full1",taskName);

% save time if Physio regressors already produced, but choose yes if not or
% changing TAPAS paramters.

run_tapas = input('Run Tapas? (y or n): ','s');
run_tapas = run_tapas == 'y';
% 
% HPF=88; % 2* duration, default automatically caculate based on durations.


global smoothed 
smoothed=true;

%% Running Pipeline - chosing from single or iterative mode 

if comparison_mode
    condition_combinations = {["STIM"],
                 ["BLANK_pre","STIM"],
                  ["BLANK_pre","STIM","BLANK_post"]
                  ["STIM","BLANK_post"]}; % Example conditions
    condition_combinations = condition_combinations(3); %choose the conditions for iteration
    switch taskName
        case "OPTO"
                positions = string(arrayfun(@(n) sprintf('Pos%d', n), 1:length(fieldnames(IDs.OPTO))-1, 'UniformOutput', false));
        case "MSTIM"
                positions = string(arrayfun(@(n) sprintf('Pos%d', n), 1:length(fieldnames(IDs.MSTIM))-1, 'UniformOutput', false));
        case "OPTO+MSTIM"
                positions = string(arrayfun(@(n) sprintf('Pos%d', n), 1:min(length(fieldnames(IDs.MSTIM)), length(fieldnames(IDs.OPTO))), 'UniformOutput', false));
    end
    positions(end+1)="Combined";

    
    if ~exist (comparison_folder,"dir")
        mkdir(comparison_folder)
    else
        choice = questdlg(sprintf('Output folder "%s" already exists. Do you want to continue to overlapping?', comparison_folder), ...
        'Folder Exists', ...
        'Yes', 'No', 'Yes');  % Default choice is 'Yes'
        switch choice
            case 'Yes'
                mkdir(comparison_folder)
            case 'No'
                disp('Exit Pipeline');
                return;  % Exit the function or script
            otherwise
                disp('Exit Pipeline');
                return;  % Exit the function or script   
        end 
    end         
    % Loop over conditions and positions
    for condition_i = 1:length(condition_combinations)
        % Set up parameters for current combination
        conditions = condition_combinations{condition_i};
        condition_folder=fullfile(subject_dirs.analysis_dir,comparison_folder,strjoin(conditions,'_'));
        mkdir (condition_folder)

        for pos_i = 1:length(positions)
            position= positions(pos_i);
%             pos_folder=fullfile(condition_folder,[position+'_data']);
%             mkdir(pos_folder)

            % construction of reference parameters
            subject_idinfo = construct_idinfo (subjectID,IDs,taskName,position);
            subject_dirs= setup_GLM_directories(position,conditions,paramfile);
           
            subject_dirs.output_dir=char(fullfile(condition_folder,subject_dirs.foldername));
            subject_dirs.condition_folder = condition_folder;
            settings_info = sprintf(['Iterative GLMs begin\n' ...
                  'Task: %s\n'...
                  'Analyzing condition: %s\n' ...
                  'Position: %s\n' ...
                  'Runs Analyzed: %s\n' ...
                  'Threshold: %s'], ...
                  taskName, char(conditions), char(position), num2str(subject_idinfo.groupIds), num2str(threshold))

            GLM_script(conditions,subject_dirs,subject_idinfo,taskName,run_tapas,threshold);
       
            fwec=round(xSPM.uc(3));
            produce_corrected_montage (subject_dirs,fwec,threshold)
                        % Specify the filename
            settings_info_file = 'settings_info_file.txt';

            % Write the formatted string to the file
            save(fullfile(subject_dirs.output_dir,"settings_info_file.txt"),"settings_info")
            
        end
    end
else 
   

% assuming the onset files have been generated by Conv. 
% setup_GLM_directories(position,conditions,param_matfile)
    
    
    GLM_script(conditions,subject_dirs,subject_idinfo,taskName,run_tapas,threshold);
    fwec=round(xSPM.uc(3));
    produce_corrected_montage (subject_dirs,fwec,threshold);      
end
   


%% GLM pipeline

% 
function [coronal_montage,axial_montage]= GLM_script(conditions,subject_dirs,subject_idinfo,taskName,run_tapas,threshold,HPF)
    if isempty(run_tapas)

        run_tapas=true;
    end 
    tissue_regressor_file_list={};
    % Loop over sessions (runs)
    for iRun = 1:length(subject_idinfo.groupIds)
        clear matlabbatch
        spm('defaults', 'FMRI');
    
        
        % choose whether construct with smoothed (2 2 2 FWHM) or unsmoothed files
        global smoothed;
        
        current_scan=construct_GLM_scaninfo(subject_idinfo.groupIds(iRun), subject_idinfo, subject_dirs,smoothed);
        
         % Initialize the scans list for the current session
        
       
        scan_file = current_scan.scan_file;
        tissue_regressor_file = current_scan.regressor_file;
        vol_num = current_scan.vol_num;  % Try to read the file
        slice_num= current_scan.slice_no;
        time_retrieval =current_scan.TR;
    
    
        tissue_regressor_file_list{end+1}= tissue_regressor_file;
        
        if exist(tissue_regressor_file_list{end}) == 2 
            fprintf('tissue regressor file already generated for the current scan %s.\n',current_scan.scan_filename);
        
            if run_tapas ==false
%         % Ask for confirmation if regressor files exist
%             choice = questdlg(' Do you want to reproduce them?', ...
%                       'Confirmation', 'Yes', 'No', 'No');
%             switch choice
%                 case 'Yes'
%                     fprintf('Reproducing regressor files for the current scan %s.\n', current_scan.scan_filename);
%                     run_tapas = true; 
%                 case 'No'
                    fprintf('Skipping the TAPAS physio for the current scan %s.\n', current_scan.scan_filename);
%                     run_tapas = false;
                    
            end
        end
    % Regressor files do not exist, proceed with processing steps
        if run_tapas

        
    
        matlabbatch{1}.spm.tools.physio.save_dir = {subject_dirs.func_dir};
        matlabbatch{1}.spm.tools.physio.log_files.vendor = 'BIDS';
        matlabbatch{1}.spm.tools.physio.log_files.cardiac = '';
        matlabbatch{1}.spm.tools.physio.log_files.respiration = ''; 
        matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {''};
        matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
        matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
        matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'last';
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices =slice_num;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = time_retrieval;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 160;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = vol_num;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = '3';
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'ECG';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.no = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.filter.passband = [0.01 2];
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.despike = false;
        matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = current_scan.regressor_filename;
        matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
        matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
        matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
        matlabbatch{1}.spm.tools.physio.model.retroicor.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.fmri_files = {current_scan.scan_file
                                                                          };
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.roi_files = subject_dirs.regressor_rois(:);
                                                                          
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.force_coregister = 'No';
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.thresholds = 0.99;
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_voxel_crop = 0;
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_components = 6;
        matlabbatch{1}.spm.tools.physio.model.movement.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
        matlabbatch{1}.spm.tools.physio.verbose.level = 2;
        matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = [current_scan.regressor_filename,'.jpg'];
        matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;
    
    
        spm_jobman('run', matlabbatch);
        end 
    end
    %% 
      
    clear matlabbatch
    
    spm('defaults', 'FMRI');
    for iRun = 1:length(subject_idinfo.groupIds)
        
      
    
        scans = {};
        
        current_scan=construct_GLM_scaninfo(subject_idinfo.groupIds(iRun), subject_idinfo, subject_dirs,smoothed);
    
        % If an error occurs, log it and try with taskName{2}
         
     
        % Construct file paths for all scans in the current run
        for vol = 1:current_scan.vol_num 
            frameFile = [current_scan.scan_file,',',num2str(vol)];
    %         change here to modify the data taking path
            scans{end+1} = frameFile;  % Add to scans list
        end
        
        % Assign scans to the current session in the batch
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).scans = cellstr(scans');
    
        %Assign the regressor file of the scan
        matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).multi_reg=tissue_regressor_file_list(iRun);
    
        % access the raw IDs of each run based on runIDs
        run_number_seq=1:length(subject_idinfo.runIds);
        runIndex =run_number_seq(subject_idinfo.runIds==subject_idinfo.groupIds(iRun)); 
        % Loop over conditions to assign condition names, onset times, and durations
        duration_sum =0;
        for iCond = 1:length(conditions)
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).orth = 1;
            
            condName = string(conditions{iCond});   
            matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).name = char(condName);
           
           % Construct the filenames for onset times and durations
            onset_file = fullfile(subject_dirs.onsetTimesDir, sprintf('%03d_%s_onset_times.txt',subject_idinfo.runIds(runIndex) , condName));
    
            duration_file = fullfile(subject_dirs.onsetTimesDir, sprintf('%03d_all_durations.txt',subject_idinfo.runIds(runIndex)));
    
            
            
    %         if exist('duration','var')==1
    %             if duration == 0||18
    %                 matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).duration = duration;
    %             end
    %         else
    %                 durations = load(duration_file);
    %                 matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).duration = durations;
    % 
    %         end
    
            % Check if the onset time and duration files exist
            if exist(onset_file, 'file') 
                % Load onset times and durations from the files
                onsetTimes = load(onset_file);
                
                % Assign condition names, onset times, and durations to the current session
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).onset = onsetTimes;
            else
        % Display an error message
            error('File not found: %s', onset_file);   
            end
    
            if exist(duration_file,'file')
                all_durations = load(duration_file);
    
                durations = all_durations(:,iCond);
    
                matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).duration = durations;
            else
        % Display an error message and use backup
                 warning('File not found: %s', onset_file);     
            
                if condName == 'STIM'
                duration= 12;
                elseif condName == 'BLANK_pre'
                duration= 4 ;
                elseif condName =='BLANK_post'
                duration = 28;
                end
            end
            duration_sum = duration_sum+mean(matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).cond(iCond).duration);
        end

    if nargin<7 || isempty (HPF)
        HPF = 2*mean(sum(all_durations,2));

    end 

    matlabbatch{1}.spm.stats.fmri_spec.sess(iRun).hpf = HPF;
            
    end
    
    matlabbatch{1}.spm.stats.fmri_spec.dir = {subject_dirs.output_dir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2; % check the TR regularity!
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 18;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 6;
    
    
    
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    %     matlabbatch{1}.spm.stats.fmri_spec.bases.fir.length = 30;
    %     matlabbatch{1}.spm.stats.fmri_spec.bases.fir.order = 15;
    
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {subject_dirs.mask};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST';
    
    %% model estimation
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    spm_jobman('run', matlabbatch(1:2));
    
    %% contrast manager 
    
    load (fullfile(subject_dirs.output_dir,"SPM.mat"));
    
    regressor_vector = [];
    for session_id = 1: length(SPM.Sess)
        num_regressors=size(SPM.Sess(session_id).col,2); % here we assume the runs all have the same number of regressors.
        
        base_contrast=convert2tcontrast(conditions);
        
        zero_paddings = zeros(1,num_regressors-length(base_contrast));
        regressor_vector=[regressor_vector [base_contrast zero_paddings]];
    end 


    matlabbatch{3}.spm.stats.con.spmmat(1) =  cellstr(fullfile(subject_dirs.output_dir,"SPM.mat"));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'pure_effect';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [base_contrast zero_paddings];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
    
    
    matlabbatch{3}.spm.stats.con.delete = 1;    
    % matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'pop';
    % matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 0 0 0];
    % matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'sess';
    % matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = '<UNDEFINED>';
    % matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = '<UNDEFINED>';
    % matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    % matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = '<UNDEFINED>';
    % matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = '<UNDEFINED>';
    % matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    spm_jobman('run', matlabbatch(3))
    
    %% Result Report
    
    load(fullfile(subject_dirs.analysis_dir,subject_dirs.parameter_file));
    matlabbatch{4}.spm.stats.results.spmmat(1) = cellstr(fullfile(subject_dirs.output_dir,'SPM.mat'));
    matlabbatch{4}.spm.stats.results.conspec.titlestr = subject_dirs.foldername;
    matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;
    matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
    matlabbatch{4}.spm.stats.results.conspec.thresh = threshold;
    matlabbatch{4}.spm.stats.results.conspec.extent = 0;
    matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{4}.spm.stats.results.units = 1;

%     matlabbatch{4}.spm.stats.results.export{1}.montage.background = cellstr('D:\CM032_bids\sub-CM032\first_level_analysis\warped_temps\temp_transformed.niiWarped.nii');
%     matlabbatch{4}.spm.stats.results.export{1}.montage.orientation = 'axial';
%     matlabbatch{4}.spm.stats.results.export{1}.montage.slices = -6:0:35;
%     hold on
%     pause(3);
%     montage_item = findobj('Type', 'figure', '-regexp', 'Name', '.*SliceOverlay.*');
%     axial_montage = fullfile(subject_dirs.output_dir,[subject_dirs.foldername,'_axial.jpg']);
%     
% 
%     


    matlabbatch{4}.spm.stats.results.export{1}.montage.background = cellstr('D:\CM032_bids\sub-CM032\first_level_analysis\warped_temps\temp_transformed.niiWarped.nii');
    matlabbatch{4}.spm.stats.results.export{1}.montage.orientation = 'coronal';
    matlabbatch{4}.spm.stats.results.export{1}.montage.slices = -24:1:28;
    
    spm_jobman('run', matlabbatch(4))

    montage_item = findobj('Type', 'figure', '-regexp', 'Name', '.*SliceOverlay.*');
    coronal_montage= fullfile(subject_dirs.output_dir,[subject_dirs.foldername,'_CORONAL.jpg']);
    sgtitle([subject_dirs.foldername,'_coronal']);


    saveas(montage_item, coronal_montage);

    assignin('base','coronal_montage',coronal_montage)
%     saveas(montage_item,axial_montage);
    
    
%     fwec=round(xSPM.uc(3));
%     matlabbatch{5}.spm.stats.results.spmmat(1) = cellstr(fullfile(subject_dirs.output_dir,'SPM.mat'));
%     matlabbatch{5}.spm.stats.results.conspec.titlestr = subject_dirs.foldername;
%     matlabbatch{5}.spm.stats.results.conspec.contrasts = 1;
%     matlabbatch{5}.spm.stats.results.conspec.threshdesc = 'none';
%     matlabbatch{5}.spm.stats.results.conspec.thresh = threshold;
%     matlabbatch{5}.spm.stats.results.conspec.extent = fwec;
%     matlabbatch{5}.spm.stats.results.conspec.conjunction = 1;
%     matlabbatch{5}.spm.stats.results.conspec.mask.none = 1;
%     matlabbatch{5}.spm.stats.results.units = 1;
%     matlabbatch{5}.spm.stats.results.export{1}.montage.background = cellstr('D:\CM032_bids\sub-CM032\first_level_analysis\warped_temps\temp_transformed.niiWarped.nii');
%     matlabbatch{5}.spm.stats.results.export{1}.montage.orientation = 'axial';
%     matlabbatch{5}.spm.stats.results.export{1}.montage.slices = -6:0:35;
%     spm_jobman('run', matlabbatch(5))
%     
  
    
%     option to also display the coronal 


end 
