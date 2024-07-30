function qcDisplay(par, numSelectedScans,norm_type)
    % Set default value for numSelectedScans if not provided
    if nargin < 2
        numSelectedScans = 3;
    end

    if nargin < 3 
        norm_type = ''
    end


    % Generate random indices for the selected scans
    totalScans = numel(par.runs);
    selectedIndices = randperm(totalScans, numSelectedScans);

    % Create a cell array to store the paths of the selected functional scans
    selectedFuncPaths = cell(numSelectedScans, 1);

    % Populate the cell array with the selected paths
    for i = 1:numSelectedScans
        selectedFuncPaths{i} = fullfile(par.runs(selectedIndices(i)).folder, [norm_type,par.runs(selectedIndices(i)).name]);
        selectedFuncPaths{i} = strcat(selectedFuncPaths{i}, ',1');
    end

    % Display the selected functional scans with SPM
    imgs = char(par.ana, char(selectedFuncPaths(:)), char(par.temp_fulldir));
    [~, image_names, ~] = fileparts(cellstr(imgs));

    spm_check_registration(imgs);

    spm_orthviews('contour', 'display', 1, [2:numSelectedScans + 2]);
    spm_orthviews('Reposition', 64.5, 64.5, 20.0);
    spm_orthviews('Zoom', -inf, 3);
    spm_orthviews('Caption', image_names);
end