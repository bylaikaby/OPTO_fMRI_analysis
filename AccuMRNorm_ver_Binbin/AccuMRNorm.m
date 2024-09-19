%% *Pipeline to normalize macaque monkey data to a standard template*
% *Inputs:*
% 
% * functional 4D .nii files
% * anatomical .nii file
% 
% Note: all prefixes used are defaults used by the algorithms.
% 
% *Written by:*
% 
% Dr. Renee Hartig (renee.hartig@tuebingen.mpg.de)
%            
% 
% Dr. Jennifer Smuda (jennifer.smuda@tuebingen.mpg.de)
% 
% With support from Dr. Yusuke Murayama (yusuke.murayama@tuebingen.mpg.de)
% 
% Last update: December 2022
%
% Modifications by J.Woller
% Dec. 2022: paralellization, step size for lin translation in mancoreg was
% tuned down to allow finer setting
% allows setting of a bounding box for DARTEL. This must be the same across
% different subjects if their images are combined for futur analysis
% added processing of c3 images
%% Set User-specific paths and settings
% 
% 1) Path and template specification
%%
clear all

expnam      = ('K07.FT1');                          			            % specify experiment file name
datapath    = ('D:/_dataset');                                   % specify datapath
toolboxpath = ('D:/toolbox/AccuMRNorm');                        % add path for toolbox
tempPath    = (fullfile(toolboxpath, '/template/NMT_v2.0'));      		            % specify template path
tempFile    = ('NMT_v2.0_sym_SS');            		                    % specify template name                        		                            
epivox      = [1 1 2];                                                           % epi voxel size

% Settings for processing of functional scans
USE_PARALLEL= true ; % true:  parallelization to process functional scans
                     % false: uses usual serial processing
% Settings for DARTEL transform of functional scans    
smoothing1  = [0 0 0]; % FWHM: Smoothing for 1st pass
smoothing2  = [2 2 2]; % FWHM: Smoothing for 2nd pass
bounding_box = [-50 -38.7 -5.9; 50 64.3 46.1];                          % Specify bounding box to be used when EPIs are normalized via DARTEL or use 'individual' to remain in each images original bbox, or use 'average" to use an average bbox per set of scans from this subject
%% Get further Parameters
% 2) Specify basic parameters needed for the analysis.
addpath(toolboxpath)
par         = parget(expnam,datapath,toolboxpath,tempPath,tempFile);        % specify experiment name
cd(par.toolboxpath)

if USE_PARALLEL
    disp('You are using the parallelized version of AccuMRNorm!')
end
%% Linear Coregistration
% 3) Linear alignment of the anatomy (mancoreg) and the functional data (norm_epi).
% Apply the transformation  (mancoreg) in the SPM GUI to the anatomical (!) file.
% Do not apply any transformation to the template itself via the GUI!
%%
% Match anatomical to functional
[mancoregvar] = mancoreg(par.temp_fulldir,par.ana);                         % variables saved in output struc used to automate affine transf matrix to all relevant EPIs.
% DO NOT close figure!

% linear alignment of EPIs
switch USE_PARALLEL
    case true  % If we run parallelized mode
        norm_epi_parallel(par.folder,mancoregvar,par.runs,par.norm_dir,par.toolboxpath, 1);
    case false % If we run regular mode
        norm_epi(par.folder,mancoregvar,par.runs,par.norm_dir,par.toolboxpath)
end
%% Tissue Probability Maps 
% 4) Generation of probability maps (through segmentation of anatomical data 
% (seg_ana)) and subsequent skull stripping (skullstrip).
%%
% probability maps for anatomy
seg_ana(par.pathana,par.anaorig,datapath,par.folder,par.temp_dir,par.norm_dir);  

% avg pob maps & skull strip
skullstrip(par.pathana,par.anaorig);                             

% re-run segmentation to get skullstripped prob maps
fnameana    = strcat('ss',par.anaorig);                                     % specify parameter

seg_ana(par.pathana,fnameana,datapath,par.folder,par.temp_dir,par.norm_dir);
%% DARTEL Normalisation (Anatomical): 1st Pass
% 5) Use DARTEL algorithm to normalize the anatomical data (dartel_norm_ana).
%%
warpedimg   = cellstr(strcat(par.norm_dir,'\rc2ss', par.anaorig));          % warped img. native after warping to templ
rimgana     = cellstr(strcat(par.norm_dir,'\rss', par.anaorig));            % realigned anatomicals

c3Images    = cellstr(strcat(par.pathana,'\c3ss',par.anaorig));             % c3-segmented img (CSF)
c2Images    = cellstr(strcat(par.pathana,'\c2ss',par.anaorig));             % c2-segmented img (GM)
c1Images    = cellstr(strcat(par.pathana,'\c1ss',par.anaorig));             % c1-segmented img (WM)

dartel_norm_ana(warpedimg,rimgana,c3Images, c2Images,c1Images);
%% DARTEL Normalisation (Functional): 1st Pass
% 6)  Use DARTEL algorithm to normalize the functional data (dartel_norm_epi).
%%
cd(par.norm_dir)
imgtemp     = dir('u_rc2ss*.nii') 	    		                   % specify deformation file 

% first pass at EPI warping
switch USE_PARALLEL
    case true  % If we run parallelized mode
        dartel_norm_epi_parallel(par.runs,par.pathepi,imgtemp,epivox,1, bounding_box, smoothing1); 
    case false % If we run regular mode
        dartel_norm_epi(par.runs,par.pathepi,imgtemp,epivox,1);
end                   
%% Manual Coregistration, Refinement of Normalization Parameters
% 7) Quality check & manual adaptations (mreg2d_gui) and export of the results 
% to .nii files (tvol2nii).
fnameana    = strcat('wrss',par.anaorig);                                   % specify parameter
ana         = fullfile(par.norm_dir,fnameana);                              % specify parameter

mreg2d_gui(par.temp_fulldir,ana);               			    % GUI for manual adaptations
tvol2nii(par.norm_dir, tempPath, tempFile); % export volume.mat to .nii after manual coreg
%% DARTEL Normalisation (Anatomical): 2nd Pass
% 8) Use DARTEL algorithm to segment (seg_ana) and normalize the anatomical 
% data (dartel_norm_ana) after manual adjustments.
%%
fnameana = strcat('wrss',par.baseFileNameNoExt,'_ref(',tempFile,')_mreg2d_volume.nii'); 
seg_ana(par.norm_dir,fnameana,datapath,par.folder,par.temp_dir,par.norm_dir);

warpedimg   = cellstr(strcat(par.norm_dir,'\rc2',fnameana));
rimgana     = cellstr(strcat(par.norm_dir,'\r', fnameana));
c3Images    = cellstr(strcat(par.norm_dir,'\c3',fnameana));
c2Images    = cellstr(strcat(par.norm_dir,'\c2',fnameana));
c1Images    = cellstr(strcat(par.norm_dir,'\c1',fnameana));

dartel_norm_ana(warpedimg,rimgana,c3Images, c2Images,c1Images);
%% DARTEL Normalisation (Functional): 2nd Pass
% 9) Use DARTEL algorithm to normalize the functional data (dartel_norm_epi) 
% after manual adjustments.
%%
cd(par.norm_dir)
imgtemp     = dir('u_rc2wrss*.nii'); 					            % specify deformation file 

% second pass at EPI warping
switch USE_PARALLEL
    case true  % If we run parallelized mode
        dartel_norm_epi_parallel(par.runs,par.pathepi,imgtemp,epivox,2, bounding_box, smoothing2); 
    case false % If we run regular mode
        dartel_norm_epi(par.partial_runs,par.pathepi,imgtemp,epivox,2);
end