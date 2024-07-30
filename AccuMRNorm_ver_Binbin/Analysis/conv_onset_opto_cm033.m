%% convert onset time for opto cm032


%% parameters

etype = 29; % Example event type
num_subtypes = 3; % Example total number of subtypes
dataset_dir = "D:\CM032.Aw1";
analysis_dir = 'D:\CM032_bids\sub-CM032\first_level_analysis';
% define the run ids to get the onset times.
mkdir(analysis_dir)
num_runs=[12,15,17,18,20,22:28,32,33,38:41,47:50,42,44];
% define the subject prefix
% refer to the naming of the dgz files
subject_id='cm32Aw1';

% %% sf
% baseDir = 'D:\\CM032_bids';
% subjectID = 'sub-CM032';
taskName = 'OPTO';
% scans = {};
% for iRun = 1:length(num_runs)  % Assuming 440 volumes per run
%     scanFileName = sprintf('r%s_task-%s_run-%02d_EPI.nii', subjectID, taskName, iRun);
%     scanPath = fullfile(baseDir, subjectID, 'func', scanFileName);
%     scans{end+1}=scanPath;
% end
%% job 

% Run this script from the directory that contains all of your subjects' data
cd (dataset_dir)
mkdir onset_times
for ii= 1:length(num_runs)
    run=num_runs(ii);
    % Load .dgz file for the current run
    dgz_file = [subject_id, '_', num2str(run,'%03d'), '.dgz'];
%     dgz_file = 'cm32Aw1_012.dgz';
    data = dg_read(dgz_file); % Load .dgz file
    onset_times={};
    % Iterate over event subtypes
    for subtype = 1:num_subtypes
        subtype_onset = selectdgevt(data, 1, etype, subtype-1);
        subtype_onset = subtype_onset/1000;
        onset_times{end+1} = subtype_onset;
       
    
    end
    %extract the onset time points
    STIM_onsets = onset_times{2};

    BLANK_pre_onsets=sort(onset_times{1});
    BLANK_post_onsets= sort(onset_times{3});
    
    all_onsets = cell2mat(onset_times);
    
    mode_third_durations = mode(onset_times{1}(2:end)-onset_times{3}(1:end-1));
    
    onset_times{1}(end+1)= onset_times{3}(end)+mode_third_durations;
    

    first_2_durations=diff(all_onsets,1,2);
    third_durations=diff([onset_times{3},onset_times{1}(2:end)],1,2);
    
    durations=[first_2_durations,third_durations];
%     %assign durations
%     BLANK_post_durations = [];
%     for i=1:length(blank_onsets)
%         
%         blank_durations(i)=18;
%     
% 
%     
%         blank_durations = blank_durations';
%     end
    % Save timing files into text files
    save([ 'onset_times/',num2str(run,'%03d'),'_BLANK_pre','_onset_times.txt'], 'BLANK_pre_onsets', '-ASCII');
    save([ 'onset_times/',num2str(run,'%03d'),'_BLANK_post','_onset_times.txt'], 'BLANK_post_onsets', '-ASCII');
    %save([ 'onset_times/',num2str(run,'%03d'),'_blank','_durations.txt'], 'blank_durations', '-ASCII');
    save([ 'onset_times/',num2str(run,'%03d'),'_STIM_onset_times.txt'],"STIM_onsets",'-ASCII');
    save([ 'onset_times/',num2str(run,'%03d'),'_all_onset_times.txt'],'all_onsets','-ASCII');
    save([ 'onset_times/',num2str(run,'%03d'),'_all_durations.txt'],'durations','-ASCII');

    

%     concatenation to form a general file
    onset_row = cellfun(@(x) num2str(x, '%f '), onset_times, 'UniformOutput', false);
%     onset_row = [onset_row{:}];
%     
%     % Save timing file into a text file
%     file_name = fullfile('all_onset_times', [num2str(run,'%03d'), '_onset_times.txt']);
%     fid = fopen(file_name, 'wt');
%     fprintf(fid, '%s\n', onset_row);
%     fclose(fid);
end


% create 3-columnar time file
% blank_onsets=num2str(blank_onsets,'%.1f ');
% type='blank';
% blank_types=repmat('0',16,1);
% durations=num2str(blank_durations,'%.1f ');
% spaces=repmat(' ',16,1);
% three_blank=horzcat(blank_onsets,spaces,durations,spaces,blank_types);
% table_name=sprintf('onset_times/3_column_onset_%s_%s.txt',taskName,type);
% writematrix(three_blank,table_name);

% STIM_onsets=num2s tr(STIM_onsets);
% durations=repmat('0',16,1);
% type='opto';
% types=repmat('1',16,1);
% spaces=repmat(' ',16,1);
% three_opto=horzcat(STIM_onsets,spaces,durations,spaces,types);
% table_name=sprintf('onset_times/3_column_onset_%s_%s.txt',taskName,type);
% writematrix(three_opto,table_name);

movefile('onset_times',analysis_dir)

cd (analysis_dir)