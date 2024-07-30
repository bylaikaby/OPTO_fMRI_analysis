function tvol2nii(normdir, tempPath, tempFile)
%% Inputs
% normdir   = direcotry with normalized volume and tform .mat files.
% anatransf = name of the transformed anatomy file.

%% Function

% Define parameters
export_nii  = 1;
nii_compa   = 'spm';                                                        % spm|amira|slicer|qform=2,d=1
data_type   = 'int16';

cd(normdir)
matfile = dir('*_volume.mat');
fprintf(' reg: %s\n',matfile.name);

% Volume inputs & categorization
tvol        = load(matfile.name,'TVOL');                                         % Load in the individual's normalized structural image
tvol        = tvol.TVOL;
tvolDepth   = size(tvol.dat,3);                                             % Determine the amount of slices in the depth (3rd) dimension

% Go through tvolDepth & find slices with laid fiducial points
for i = 1:tvolDepth
    datArray{i} = find(any(tvol.dat(:,:,i)));                               % use logical operation (any) to find anything other than 0 across slices
end

sliceID     = cellfun('isempty', datArray);                                 % Logically identify whether slices are empty or not (empty here = 1)
firstSlice  = find(sliceID == 0, 1, 'first');                               % Identify firstSlice that is not empty

% Vol slice replace to carry a user-defined interpolation over two additional slices to minimize work on the manual back end
intvl = input('Please enter the interval of slices on which fiducial points were laid:');
btwintvl = intvl-1;

counter = firstSlice;

for replval = firstSlice:intvl:tvolDepth
    
    for m = 1:btwintvl
        
        k = counter + m;
        tvol.dat(:,:,k) = tvol.dat(:,:,replval);
        
    end
    counter = counter+intvl;
end

tic
tvol.dat = int16(round(tvol.dat));

% Establish image header information
[fp,fr] = fileparts(matfile.name);                                               % Image file location & name
imgdim = [4 size(tvol.dat,1) size(tvol.dat,2) size(tvol.dat,3) 1];          % Set-up image dimensions
pixdim = [3 tvol.ds(1) tvol.ds(2) tvol.ds(3)];                              % Set-up pixel dimensions

if any(export_nii)
    % If exporting as nii, write nii header & image file
    imgfile = fullfile(fp,sprintf('%s.nii',fr));
    hdr = nii_init('dim',imgdim,'pixdim',pixdim,...
        'datatype',data_type,'glmax',intmax(data_type),...
        'niicompatible',nii_compa);
else
    % Or write an anz image/hdr
    imgfile = fullfile(fp,sprintf('%s.img',fr));
    hdr = hdr_init('dim',imgdim,'pixdim',pixdim,...
        'datatype',data_type,'glmax',intmax(data_type));
end

fprintf(' img: %s\n',imgfile);                                              % Exported image name
anz_write(imgfile,hdr,tvol.dat);                                            % Write out the exported image

setOrigin = spm_vol(fullfile(normdir, imgfile));                            % Set origin to match template 
tempOrigin = spm_vol(strcat(tempPath, '\', tempFile, '.nii'));              % Load in template origin
setOrigin.mat = tempOrigin.mat;                                              

spm_write_vol(setOrigin, tvol.dat);                                         % Write out end result

toc

disp('Done')

end
