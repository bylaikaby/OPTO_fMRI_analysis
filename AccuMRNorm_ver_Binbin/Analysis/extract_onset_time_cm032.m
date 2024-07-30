%% convert onset time for opto cm032

% First define the data paths and analysis directory where the major GLM
% takes place.
% 
% Followed by dgz_viewer to check the info necessary for the data extraction
% 
% Then it calls the extract_onset_times functions actuator.
%% parameters


dataset_dir = "D:\CM032.Aw1";
analysis_dir = 'D:\CM032_bids\sub-CM032\first_level_analysis';

% Ensure the analysis directory exists
if ~exist(analysis_dir, 'dir')
    mkdir(analysis_dir);
end

% define the run ids to get the onset times.
num_runs=[12,15,17,18,20,22:28,32,33,38:41,47:50,42,43,44];

% define the subject prefix
% refer to the naming of the dgz files
subject_id='cm32Aw1';


% dgz_file_sample_1 = fullfile(dataset_dir,sprintf('%s_%03d.dgz', subject_id, num_runs(1)));
% dgz_file_sample_2 = fullfile(dataset_dir,sprintf('%s_%03d.dgz', subject_id, num_runs(end)));
% dgzviewer(dgz_file_sample_1);
% dgzviewer(dgz_file_sample_2);
% 
% etype = input('Enter event type (etype): ');
% num_subtypes = input('Enter the number of subtypes: ');
% 

% etype = 29; % Example event type
% num_subtypes = 3; % Example total number of subtypes


extract_onset_times (num_runs, subject_id, dataset_dir, analysis_dir, etype, num_subtypes);



