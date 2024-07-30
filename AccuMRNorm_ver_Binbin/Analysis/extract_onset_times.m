
function extract_onset_times(num_runs, subject_id, dataset_dir, analysis_dir, etype, num_subtypes)
    % 1. convert_onset_times Processes onset time data for given runs and subject.
    % 2. contains a QC module to compare the duration file extracted to see if
    % they are consistent
    %
    % Inputs:
    %   num_runs - Array specifying the run IDs.
    %   subject_id - Identifier for the subject.
    %   dataset_dir - Directory containing the dataset files.
    %   analysis_dir - Directory where analysis results will be stored.
    %   etype - Event type to be analyzed.
    %   num_subtypes - Total number of subtypes to be processed.
    %
    % Output:
    %   This function does not return any values. It saves onset time and duration
    %   data into ASCII text files within the specified analysis directory
    %   (onset_times)

        

    % Change working directory to dataset directory
    cd(dataset_dir);
    mkdir onset_times
    
    

    all_durations = {};
    
    if isempty(etype) && isempty(num_subtypes)
        dgz_file_sample_1 = fullfile(dataset_dir,sprintf('%s_%03d.dgz', subject_id, num_runs(1)));
        dgz_file_sample_2 = fullfile(dataset_dir,sprintf('%s_%03d.dgz', subject_id, num_runs(end)));
        dgzviewer(dgz_file_sample_1);
        dgzviewer(dgz_file_sample_2);
        etype = input('Enter event type (etype): ');
        num_subtypes = input('Enter the number of subtypes: ');
    end

    % Process each run
    for ii = 1:length(num_runs)
        run = num_runs(ii);
        dgz_file = sprintf('%s_%03d.dgz', subject_id, run);
        data = dg_read(dgz_file); % Load .dgz file
        onset_times = {};
        

        % Process each event subtype
        for subtype = 1:num_subtypes
            subtype_onset = selectdgevt(data, 1, etype, subtype - 1) / 1000;
            onset_times{end + 1} = subtype_onset;
        end

        % Extract and sort onset times
        BLANK_pre_onsets = sort(onset_times{1});
        BLANK_post_onsets = sort(onset_times{3});
        STIM_onsets = onset_times{2};
        all_onsets = cell2mat(onset_times);
        
        % for the convenience of creating durations, add additional end
        % term 
        mode_third_durations = mode(onset_times{1}(2:end)-onset_times{3}(1:end-1));
    
        onset_times{1}(end+1)= onset_times{3}(end)+mode_third_durations;
    

        first_2_durations=diff(all_onsets,1,2);
        third_durations=diff([onset_times{3},onset_times{1}(2:end)],1,2);
    
        durations=[first_2_durations,third_durations];

        % Save data to files
        save(sprintf('onset_times/%03d_BLANK_pre_onset_times.txt', run), 'BLANK_pre_onsets', '-ASCII');
        save(sprintf('onset_times/%03d_BLANK_post_onset_times.txt', run), 'BLANK_post_onsets', '-ASCII');
        save(sprintf('onset_times/%03d_STIM_onset_times.txt', run), 'STIM_onsets', '-ASCII');
        save(sprintf('onset_times/%03d_all_onset_times.txt', run), 'all_onsets', '-ASCII');
        save(sprintf('onset_times/%03d_all_durations.txt', run), 'durations', '-ASCII');

        all_durations {end+1} = durations;
    end
    
    

 

    % Load and compare durations
    tolerance = 0.1;

    durations_consistent = true;

    for i = 2:length(all_durations) % Start from the second file
        % Compute absolute differences between current and first duration array
        differences = abs(all_durations{1} - all_durations{i});
        if any(differences(:) > tolerance)
            durations_consistent = false;
            file_id = num_runs(i);
            fprintf('Warning: Durations in file %d exceed the tolerance of %0.1f seconds.\n', file_id, tolerance)
        end
    end
    if durations_consistent
        disp ('Durations are consistent across all runs.')
    end

    % Move onset times folder to the analysis directory
    movefile('onset_times', analysis_dir);

    % Change working directory back to the analysis directory
end
