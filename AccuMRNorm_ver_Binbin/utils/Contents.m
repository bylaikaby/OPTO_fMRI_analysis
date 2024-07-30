% UTILS -- Utility functions
%
%   hutils             - - Helpwin Utils: List the contents of ./Mri/Matlab/Utils Directory
%
% File Handling
%   cdws               - - Go to the workspace directory
%   catfilename        - - Create filename of type "mat,dgz,etc" of experiment EXPNO
%   cddemo             - - Go to the demo directory
%   gethome            - - Returns the full path of the session's home directory
%   getdirs            - - Returns the platform-dependent directory structure
%   getfilename        - - Get the filename from Ses and ExpNo or GrpName
%   getfilenames       - - returns relevant dirs/files for a given experiment ExpNo
%   goto               - - Read session file and go to the corresponding directory
%   gotox              - - Read session file and go to the corresponding directory
%   gotos              - - Read session file and go to the corresponding directory
%   getdirfrompath     - - Extracts directory from fullpath (e.g. f:/temp/)
%   getnamefrompath    - - get filename from full pathname
%   getpatlen          - - get the length of a pattern (blank-fix-stim-blank) in points
%
% Type-Finders
%   isgrpname          - - Returns 1 if GrpName is a group-name, otherwise 0
%   isimaging          - - Returns whether is a recording/imaging session
%   isinfile           - - Checks whether VarName is in file SesName/ExpNo
%   isinjection        - - Returns whether a group was collected during or after inection (anesth, neuromod)
%   ismicrostimulation - - Returns whether is a group of microstimulation data
%   ismovie            - - Returns whether the stimulus was a movie-clip
%   isnormal           - - Returns whether is a recording/imaging group was normal (Control)
%   isawake            - - Returns whether a group was collected with awake animals or not
%   isnostim           - - Returns whether recording/imaging group data were collected w/out stimulation
%   isrecording        - - Returns whether is a recording/imaging session
%   istransition       - - Returns whether the group data were during "transition" (anesth-recovery)
%   isstim             - - Returns whether the group data were collected with a sensory stimulus
%   issig              - - Returns 1 if the input is a signal structure.
%   trialstatus        - - returns anap.gettrial.status
%
% Information on Files and Structures
%   whoupdated         - - Lists all recently updated Matlab scripts.
%   whofile            - - List file variables by calling who(filename,'-file',...)
%   infowho            - - Searches for variable "VarName" in all files of a session
%   info1who           - - List the variables in the 1st file of each group
%   infogrpwho         - - List the variables of each MAT file that belongs to the group GrpName
%   infoblp            - - List the variables in the 1st file of each group
%   infoevt            - - Display Event/Stim Information (Requires dgz and acqp/reco files)
%   infoexp            - - Displays information regarding the experiment ExpNo of SESSION
%   infogrp            - - Display the fields of all groups of a session
%   infomissing        - - Display missing mat files from a session
%   infosupgrp         - - Lists & returns all super groups from description files
%   infoses            - - Display information for each group of a session using raw data
%
% Project and Session Related Information Retrieval
%   allses             - - Mark all analyzed sessions
%   getproj            - - Select project type (OLD DATA -- Nature paper)
%   getses             - - Set up Ses structure with all session's parameters
%   getactmapmask      - - Get the index of modulating voxels from the "actmap" group
%   getactspont        - - Returns the experiments of action and spontaneous activity supergroups
%   getacqp            - - get default parameters for data acquisition.
%   getanap            - - Returns default analysis parameters
%   getexps            - - Get EXPS from group(s).
%   getgroups          - - Returns a cell-array of all group-structures of a session
%   getgroupsbyroiname - - Returns the group-structure from RoiName
%   getgrp             - - Returns the group-structure by experiment number or group name.
%   getgrpbyname       - - Returns the group-structure of group GrpName
%   getgrpbyroiname    - - Returns the group-structure from RoiName
%   getgrpfilenames    - - Returns a cell-array of a session's groupfile-names
%   getgrpnames        - - Returns a cell-array of a session's group names
%   getgrproi          - - Returns all references groups of a session
%   getactmap          - - Returns all references groups of a session
%   getexpfromgrp      - - Get name of group from experiment
%   getbriefstmt       - - Get timing for stimuli of shorter duration than TR
%   initgrpvals        - - Initializes all signals that can be used for grouping MAT files
%   lsgrp              - - ls group fields
%   lsgrpnames         - - ls group fields
%   lspar              - - ls par from PARsession.mat for ExpNo and Field (e.g. img)
%   validexps          - - Returns all valid experiments defined in group sturctures
%   validgrps          - - Returns all valid groups defined in group sturctures
%   varargin2cmd       - - convert varargin to a text string for plot-title
%
% Signal Processing
%   sigexist           - - Check if signal exist in a given experiment-file
%   xform              - - converts Sig's unit accoring to 'Method' and 'Epoch'
%   tosdu              - - convert signal values to SD units computed over baseline activity
%   getStimIndices     - - Gets time indices of specified object/period.
%   getbaseline        - - get baseline activity of signal "Sig"
%   xsigdim            - - Creates a vector of size length(Dim) and appropriate units
%   catflt             - - band/low pass filtering of cat-structures
%   myfft              - - Get power spectrum of data dat and rate fs
%   myginput           - - Graphical input from mouse.
%   mysin              - - Get power spectrum of data dat and rate fs
%   sigfftfilt         - - Filtering by FFT provides no phase lag and sharpest
%   sigfft             - - Fast Fourier transform for our neural (BLP) and fMRI (roiTs) signals
%   sigupdate          - - Updates the info.date/time structure of our signals
%   siginterp1         - - applies data interpolation to the signal.
%   sigresample        - - resamples the signal.
%
% Signal Resorting (Old Code) all new relevant functions are under ./evt
%   sorttrials         - - sort randomly presented trials
%   getepoch           - - Reshapes and permutes the output of the sorttrials.m
%   condcat            - - Merge different experimental conditions along NoObsp dim
%   avgtrials          - - Average Sig of all trials of a multi-trial observation period
%   gettrgtrial        - - extract trials from observation period
%   getpat             - - get pattern of trials from observation period
%   sig2trial          - - Resort signal to individual trials
%   subcln             - - Returns (squeezed) the Cln.dat(:,:,getflashtrials)
%   gettrig            - - get patterns "Pattern" from obsp with Trig/Pre/Pos specs
%   trana              - - analyzed each trial
%
% Groupping Utilities
%   grpmake            - - Group signals defined in "SigName" in group GrpName
%   sctcat             - - Conctaneate structures
%   sctmerge           - - replaces/adds fields of A with those of B.
%   catsig             - - Concatanate signals from mat files
%   catsig_awake       - CATSIG - Concatanate signals from mat files
%   tstvideo           - - Test Video routine which makes our matlab movies
%   supgrpmake         - - Makes super-averages from the groups defined in Ses.CTG.SG 
%
% General Small Utilities
%   emacs              - - invokes emcas editor
%   getcond            - - Split the file data into trial and observation periods.
%   getRespIndicesVSig - - get a struct of response indices from'VMua' etc.
%   getpow2            - - Get the next smaller or greater power of 2 number
%   getstmimages       - - generate images of stimuli from 'stmobj' structure.
%   gettimebase        - - Use Sig.dx and size(Sig.dat,1) to create time base
%   gettimestring      - - get time as a string
%   pareval            - - Evaluate parameters passed as a structure.
%   num2str2cell       - - It converts numbers to cell array of strings
%   dal2cln            - - converts DAL' rivalry data to our format
%   dat2model          - - Makes model from .pts and dumps in filename
%   getortho           - - compute orthogonal line to p1-p2 segements with length d
%   minmax             - - Ranges of matrix rows.
%   mksines            - - Make sine waves
%   mksound            - - Make a wave file and dump on f:/Talks/Movies
%   mhelp2html         - - Dumps help discription as html file with minimum tags.
%   yesorno            - - Ask user if something is valid or not
%   parseinput         - - Finds first string argument.
%   exptime            - - returns date/time string of the experiment.
%   showfig            - - brings the current figure inside the monitor.
%   ess2smr            - - exports adf/adfw/Cln data as 'smr' format for CED's Spikes2
%
% Fixup Routines
%   fixstring          - - replaces "_" with "\_" for compatibility issues
%   fixup              - - Fixing/Replacing/Adding new pars/vars
%   clnfile            - - Cleans files by removing any variables except those defined in VarNames
%
% NKL, 19.07.04
% NKL, 06.01.06, 14.01.06
