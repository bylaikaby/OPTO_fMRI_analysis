% setNiiOrientation: Reorients a single NIfTI image by overwriting the sForm matrix and changing the qfactor.
%
% Author: Joshua P. Woller, MPI for Biological Cybernetics
%
% Inputs:
%   - niiName: A string specifying the path to the NIfTI file to be reoriented.
%   - sMatrix: A 4x4 transformation matrix for reorientation (optional, default is specified).
%   - qfactor: A scalar value for changing the qfactor (optional, default is specified).
%   - compress: A logical value indicating whether to compress the NIfTI image when writing (optional, default is true).
%
% This function reorients a NIfTI file by updating the sForm matrix and qfactor in the header.
% It is useful for correcting the orientation of NIfTI files when needed.
%
function new_setNiiOrientation(niiName, sMatrix, qfactor, if_compress)

% Check if sMatrix and qfactor arguments are provided, otherwise use defaults.
    if nargin < 2 || isempty(sMatrix)
        % Get the dimensions of the NIfTI file
        niiHdr = niftiinfo(niiName);
        dims = niiHdr.ImageSize(1:3);

%         % Calculate scaling factors for each dimension
%         scaleFactors = [96/dims(1), 96/dims(2), 40/dims(3)];
% 
%         % Set default sMatrix with scaling factors and last row [50 50 -10 1]
%         sMatrix = [diag([scaleFactors,1])];
        sMatrix =diag([-0.39/1.5,0.38/1.5,0.25,1]);

        sMatrix(4,:) = [25,-25,0,1];

        disp('Using default sMatrix:');
        disp(sMatrix);
    end

    if nargin < 3 || isempty(qfactor)
        qfactor = -1;
        disp(['Using default qfactor: ' num2str(qfactor) '.']);
    end

    if nargin < 4 || isempty(if_compress)
        if_compress = false;
    end


% Input checks for sMatrix, qfactor, and compress
if ~isequal(size(sMatrix), [4, 4])
    error('sMatrix must be a 4x4 matrix.');
end
if ~(qfactor == 1 || qfactor == -1)
    error('qfactor must be either +1 or -1.');
end
if ~islogical(if_compress)
    error('compress must be a logical value.');
end

% File loading
niiHdr = niftiinfo(niiName); % Read NIfTI header
niiVol = niftiread(niiName); % Read NIfTI volume

disp(['Setting header for file: ' niiName])

% Set the transformation matrix, qfactor, and description in the header.
niiHdr.Transform.T = sMatrix;
niiHdr.QFactor = qfactor;
niiHdr.Description = 'Orientation reset using MATLAB.';    
% Write the updated NIfTI image to a .nii file, with optional compression.
niftiwrite(niiVol, niiName, niiHdr, "Compressed", if_compress);

end
