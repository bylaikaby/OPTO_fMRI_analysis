function fMRI_preprocessing_par(par)
% NHP fMRI Preprocessing by SPM12
%
% Owner: Renee Hartig
% Collaborator(s): Celia Foster
%
% Requisite Inputs:
% par - A structure containing parameters and paths for preprocessing.

%% Housekeeping
clearvars -except par
spm fmri

%% File Selection
% Functional Scans
folders = {par.runs.name}; % Use the name field of par.runs to get the file paths
folders = folders';
for i = 1:numel(folders)
    folders{i} = fullfile(par.runs(i).folder,folders{i}); 
    folders{i} = cellstr(folders{i});
end

% Anatomical Scan
anatomical = cellstr(par.ana); % Use the 'ana' field of par

%% Begin Preprocessing
% Save outputs to the experiment's 'preprocessing' folder
working_folder = fullfile(par.work_dir, 'preprocessing');
mkdir(working_folder);
cd(working_folder);

% Realignment (Est & Write)
matlabbatch{1}.spm.spatial.realign.estwrite.data = folders;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

% ANA2EPI registration to eliminate misalignment
matlabbatch{2}.spm.spatial.coreg.estwrite.ref = cfg_dep('Realign: Estimate & Reslice: Mean Image', ...
    substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), ...
    substruct('.','rmean'));
matlabbatch{2}.spm.spatial.coreg.estwrite.source = anatomical;
matlabbatch{2}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 7;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'c';


spm_jobman('run', matlabbatch);

