function [par]= inspect_scansinfo(par)
% Function to inspect information of specified EPIs
% Inputs:
%   - par: Parameter structure

% Initialize variables to store the reference information
referenceInfo = [];
variedIndices = [];
is_varied = 0;
varied_count = 0;
subject_epis = [];

% Variables to track abnormal EPIs
nimages = [];
abnormalIndices = [];  % Store indices of abnormal EPIs

for i = 1:length(par.runs)
    index = i;
    func = fullfile(par.runs(index).folder, par.runs(index).name);
    v_func = spm_vol(func);
    nimage = length(v_func);
    di = spm_imatrix(v_func(1).mat);
    epivox = abs(di(7:9));  % EPI voxel size
    tr = v_func(1).private.timing.tspace;
    formatSpec = 'EPI [%s] has [%d] images, TR [%ds] and voxel size [%g %g %g]\n';

    subject_epis(i).info = sprintf(formatSpec, par.runs(i).name, nimage, tr, epivox(:));

    % Collect the number of images
    nimages = [nimages, nimage];

    % Store the information from the first EPI as reference
    if i == 1
        referenceInfo = {nimage, epivox(:)};
    else
        % Check if the current EPI's information matches the reference
        if ~isequal({nimage, epivox(:)}, referenceInfo)
            is_varied = 1;
            varied_count = varied_count + 1;
            variedIndices = [variedIndices, i];
            referenceInfo = {nimage, epivox(:)};
        end
    end
end

% Get anatomical information
v_anat = spm_vol(par.ana);
di = spm_imatrix(v_anat.mat);
anavox = abs(di(7:9));
tr = v_anat.private.timing.tspace; % voxel size

formatSpec = 'ANAT [%s] has TR [%ds] and voxel size [%g %g %g]\n\n';
subject_ana = sprintf(formatSpec, par.anaorig, tr, anavox(:));

if is_varied == 1
    subject_epi_varied = sprintf('EPI information varies.');
else
    subject_epi_varied = sprintf('EPI information constant.');
end

subject = sprintf('For subject %s:\n', par.folder);
subject_info = [subject, subject_ana, subject_epis(:).info, subject_epi_varied];
display(subject_info);

% Calculate mean and standard deviation of the number of images
mean_nimages = mean(nimages);
std_nimages = std(nimages);

% Define threshold for abnormality (e.g., 2 standard deviations)
threshold = 2;

% Identify abnormally different EPI files
fprintf('Abnormally different EPI files:\n');
for i = 1:length(nimages)
    if abs(nimages(i) - mean_nimages) > threshold * std_nimages
        fprintf('EPI [%s] has [%d] images (Mean: %.2f, Std: %.2f)\n', par.runs(i).name, nimages(i), mean_nimages, std_nimages);
        abnormalIndices = [abnormalIndices, i];
    end
end

% Ask whether to remove abnormal runs
if ~isempty(abnormalIndices)
    userResponse = input('Do you want to remove the abnormal runs? (y/n): ', 's');
    if lower(userResponse) == 'y'
        % Create a logical index for removing abnormal runs
        removeMask = true(1, length(par.runs));
        removeMask(abnormalIndices) = false;
        
        % Update par.runs by retaining only the non-abnormal runs
        par.runs = par.runs(removeMask);
        fprintf('Abnormal runs removed.\n');
    else
        fprintf('Abnormal runs retained.\n');
    end
end

% end
