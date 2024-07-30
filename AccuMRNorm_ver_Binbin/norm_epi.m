function norm_epi(folder,mancoregvar,epiFiles,normdir)
%% Inputs
% folder      = experiment folder.
% runs        = number of runs in this experiment.
% mancoregvar = parameters obtained in the normalization script by doing the linear realignment.
% pathepi     = path to functional data.
% normdir     = direcotry with normalized volume and tform .mat files.

m = input('Done with manual linear alignment? (Y/N)','s');
if m == 'Y'
    
   figname = fullfile(normdir,strcat(folder, '_affine_tform'));
   savefig(strcat(figname,'.fig'));
    
    %% Function
    tic
    for i = 1:length(epiFiles)
        epi = fullfile(epiFiles(i).folder, ['r',epiFiles(i).name]);
   
        fctImg  =  spm_vol(epi);
        
        x = size(fctImg,1);
        
        str_accum   = strings(length(fctImg),1);                            % ind repeating interval 1:300 integers
        numVol      = repmat(1:x, 1, length(epiFiles));
        
        for i = 1:length(fctImg)
            str_accum{i} = strcat(fctImg(i).fname, ',',num2str(numVol(i)));
        end
        
        P = char(pad(str_accum));                                           % set up P = EPInum x character array indicating EPI file
        
        % Call affine transf values (figure must still be open)
        angl_pitch  = get(mancoregvar.hpitch,'Value');
        angl_roll   = get(mancoregvar.hroll,'Value');
        angl_yaw    = get(mancoregvar.hyaw,'Value');
        dist_x      = get(mancoregvar.hx,'Value');
        dist_y      = get(mancoregvar.hy,'Value');
        dist_z      = get(mancoregvar.hz,'Value');
        
        spm_defaults;                                                               % run spm_defaults, standard settings
        
        mat = spm_matrix([dist_x dist_y dist_z angl_pitch angl_roll angl_yaw 1 1 1 0 0 0]); % linear transf matrix
        
        save(strcat(folder, '_affine_tform', '.mat'));
        
        if det(mat)<=0                                                              % copied from spm_image.m
            spm('alert!','This will flip the images',mfilename,0,1);
        end
        
        Mats = zeros(4,4,size(P,1));
        
        % Read current img orientations& apply relevant transf
        for i=1:size(P,1)
            Mats(:,:,i) = spm_get_space(P(i,:));
            spm_progress_bar('Set',i);
            spm_get_space(P(i,:),mat*Mats(:,:,i));
        end
        
        % checking temp data type
        tmp = spm_get_space([mancoregvar.targetimage.fname ',' num2str(mancoregvar.targetimage.n)]);
        
        if sum((tmp(:)-mancoregvar.targetimage.mat(:)).^2) > 1e-8
            spm_image('init',mancoregvar.targetimage.fname);
        end
        
        toc
        
        disp('Done')
        
    end
    movefile(strcat(pwd,'\',folder,'_affine_tform.mat'),(normdir));
elseif m == 'N'
    disp('Linear alignment not done');
end
end
