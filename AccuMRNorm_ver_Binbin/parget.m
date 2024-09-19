function [par] = parget (expnam,datapath,toolboxpath,tempPath,tempFile)
%% function to retrieve experiment information per subject
% data structure: seperate folder for each experiment in the datapath
% Inputs:
% expnam = experiment name.
% datapath as defined in the normalization script.

%% specification of paths 
par.temp_dir    = tempPath;  										    	% template path
par.temp        = tempFile;                                                 % template file name

par.temp_fulldir = strcat(par.temp_dir, '\', par.temp, '.nii');

par.toolboxpath = toolboxpath;                                              % specify matlabpath

par.folder      = expnam;

cd(datapath)
cd(par.folder)
mkdir 'norm'                                                                % create 'norm' folder for saving output files (if none exists already)

%% adapt the path and filesnames accordingly
par.norm_dir    = fullfile(datapath,par.folder,'\norm');                    % specify path for saving output files
par.pathana     = fullfile(datapath,par.folder,'\anat');                     % specify path for the anatomy file
par.pathepi     = fullfile(datapath,par.folder,'\func');                    % specify path for functional files
par.work_dir    = fullfile(datapath,par.folder);                            % specify data location

%%  read in relevant functional & anatomical files
cd(par.pathepi)
par.runs        = dir('sub*.nii');                                             % determined number of func runs 
par.runs        = par.runs(~startsWith({par.runs.name}, 'sw'));
% par.realigned_runs = dir('rsub*.nii')
cd(par.pathana)
par.anaorig = uigetfile({ '*.nii'}, 'Select Anatomical File', par.pathana)                                           % directory with original anatomy
par.ana     = fullfile(par.pathana,par.anaorig);                            % full anatomical file

[folder, par.baseFileNameNoExt, extension] = fileparts(par.anaorig);        % pull out the base ana file name without extension


end
