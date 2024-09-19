function check_and_replace_func_nans(par)
    % Define the output directory where the modified files will be saved
%     output_dir = fullfile(par.work_dir, 'modified_func');
%     
%     % Create the output directory if it doesn't exist
%     if ~exist(output_dir, 'dir')
%         mkdir(output_dir);
%     end

    % Iterate through all runs in par.runs
    for iRun = 1:length(par.runs)
        % Get the functional file path
        func_file = fullfile(par.pathepi, ['r',par.runs(iRun).name]);
        
        % Load the NIfTI file
        nifti_info = niftiinfo(func_file);  % Get metadata of the NIfTI file
        img_data = niftiread(func_file);    % Read the NIfTI data
        
        % Check for NaN values in the data
        if anynan(img_data)
            fprintf('NaN values detected in %s. Replacing NaNs with zeros...\n', func_file);
            
            % Replace NaN values with zeros
            img_data(isnan(img_data)) = 0;
            
            % Create a new file name for the modified data in the output directory
%             [~, name, ext] = fileparts(func_file);
%             modified_file = fullfile(output_dir, [name, ext]);
%             
            % Save the modified data without compression
%             nifti_info.Filename = modified_file;  % Update the filename in the NIfTI info
            niftiwrite(img_data, func_file, nifti_info);  % Save without compression
        end
        
        fprintf('Processed %s.\n', func_file);
    end
end