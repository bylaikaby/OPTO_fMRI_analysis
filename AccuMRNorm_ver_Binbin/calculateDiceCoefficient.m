function calculateDiceCoefficient(par)
    datapath = par.work_dir;
    normfile= par.normfile;
    temp= par.temp_fulldir;

    

    % Create quality check folder
    cd (par.norm_dir)
    qualityCheckPath = fullfile(datapath,'norm', 'qualitycheck');
    mkdir(qualityCheckPath);

    % Copy norm and temp images to quality check folder
    normimgOrig = fullfile(datapath, 'norm', normfile);
    copyfile(normimgOrig, qualityCheckPath);
    copyfile(temp, qualityCheckPath);

    % Create mask by binarizing the template
    binarize_temp(temp, 'tempbi');

    % Orient images in the same dimensions
    normimg = fullfile(datapath,'norm', 'qualitycheck', normfile);
    rnorm = fullfile(datapath,'norm', 'qualitycheck', ['r', normfile]);
    img_orient('tempbi.nii', normimg, rnorm);

    % Mask norm image (mask_norm) & binarize to remove background noise (binarize_norm)
    rtempbi = fullfile(qualityCheckPath, 'rtempbi.nii');
    mask_norm(rnorm, rtempbi, 'rnormm');
    binarize_norm('rnormm.nii','rnormmbi');

    % Compute the dice coefficient
    dicecoeff('rnormmbi.nii', 'rtempbi.nii');


end
