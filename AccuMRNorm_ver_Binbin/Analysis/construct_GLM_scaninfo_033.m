

function scanInfo = construct_GLM_scaninfo_033(groupId, subject_idinfo, subject_dirs, smoothed)
    
    if (nargin<4) or isempty(smoothed)
        smoothed = false;
    end 
        % Check which group the ID belongs to and construct the scan filename
    if ismember(groupId, subject_idinfo.optoIds)
        scanIndex = find(subject_idinfo.optoIds == groupId);  % Correct reference to optoIds from subject_ids
        if smoothed==false
            scan_filename = sprintf('r%s_task-%s_run-%02d_EPI.nii', subject_idinfo.subjectID, 'OPTO', scanIndex);  % Use groupIds for subjectID
        elseif smoothed == true
            scan_filename = sprintf('sr%s_task-%s_run-%02d_EPI.nii', subject_idinfo.subjectID, 'OPTO', scanIndex);  % Use groupIds for subjectID
        end
    elseif ismember(groupId, subject_idinfo.mstimIds)
        scanIndex = find(subject_idinfo.mstimIds == groupId);  % Correct reference to mstimIds from subject_ids
        if smoothed==false
            
            scan_filename = sprintf('r%s_task-%s_run-%02d_EPI.nii', subject_idinfo.subjectID, 'MSTIM', scanIndex);  % Use groupIds for subjectID
        elseif smoothed == true
             scan_filename = sprintf('sr%s_task-%s_run-%02d_EPI.nii', subject_idinfo.subjectID, 'MSTIM', scanIndex );  % Use groupIds for subjectID
        end
        else
        error('Group ID does not match any known categories.');
    end
    

    output_dir=subject_dirs.output_dir;
    func_dir=subject_dirs.func_dir;
    % Construct the filenames for the scan and the regressor
    scan_file = fullfile(func_dir, scan_filename);
    regressor_filename = sprintf('tissue_regressors_%s.txt', scan_filename);
    regressor_file = fullfile(func_dir, regressor_filename);

    % Attempt to read the file metadata
    vol_num = length(spm_vol(scan_file));  % Read the file to get the volume number
    slice_no = niftiinfo(scan_file).ImageSize(3);  % Read the file to get the slice number
    time_retrieval=niftiinfo(scan_file). PixelDimensions(4);
    % Create a structure to hold all the relevant scan information
    scanInfo = struct(...
        'scan_filename', scan_filename, ...
        'scan_file', scan_file, ...
        'regressor_filename', regressor_filename, ...
        'regressor_file', regressor_file, ...
        'vol_num', vol_num, ...
        'slice_no', slice_no,...
        'TR', time_retrieval ...
    );
end
