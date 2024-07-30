function quickDiceCoefficient(input,temp)
   

    
    % Create mask by binarizing the template
    binarize_temp_quick(temp, 'tempbi');

    % Orient images in the same dimensions
    normimg = input;
    [folder,normname,ext]= fileparts(input);
    [~,tmpname,~]= fileparts(temp);
    if ~isempty(folder)
        cd (folder);
        test_name=strcat("dice_coefficient_",normname,"_&__",tmpname);
        mkdir (test_name);
        cd (test_name);
    else
        mkdir (test_name);
        cd (test_name);
    end
    binarize_temp_quick(temp, 'tempbi');    
    rnorm = ['r', normname,'.nii'];
    rnorm = fullfile(folder,rnorm);
    img_orient('tempbi.nii', normimg, rnorm);

    % Mask norm image (mask_norm) & binarize to remove background noise (binarize_norm)
    rtempbi = 'rtempbi.nii';
    mask_norm(rnorm, rtempbi, 'rnormm');
    binarize_norm('rnormm.nii','rnormmbi');

    % Compute the dice coefficient
    DC=quick_dicecoeff('rnormmbi.nii', 'rtempbi.nii');
    txt=fprintf('The dice coefficient of %s and %s is %f\n',normname, tmpname, DC);
    save("dice_coefficient.txt","txt");
    delete ('*.nii');
end
    