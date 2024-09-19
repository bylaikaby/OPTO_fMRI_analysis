function dartel_norm_ana(warpedimg,rimgana, c3Images, c2Images,c1Images)
%% Inputs
% warpedimg = warped image native after warping to template.
% rimgana   = realigned anatomical files.
% c2Images  = c2-segmented image (grey matter).
% c1Images  = c1-segmented image (CSF ).

%% Function
% Create Dartels Template
matlabbatch{1}.spm.tools.dartel.warp.images                 = {warpedimg};
matlabbatch{1}.spm.tools.dartel.warp.settings.template      = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform         = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its  = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K    = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its  = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K    = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its  = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K    = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its  = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K    = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its  = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K    = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its  = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K    = 6;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg   = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc     = 8;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its     = 8;

% Normalize to Standard Space
matlabbatch{2}.spm.tools.dartel.mni_norm.template           = {''};         % takes monkey template by default
matlabbatch{2}.spm.tools.dartel.mni_norm.data.subjs.flowfields(1) = cfg_dep('Run Dartel (create Templates): Flow Fields', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '()',{':'}));
matlabbatch{2}.spm.tools.dartel.mni_norm.data.subjs.images  = {c3Images c2Images c1Images};
matlabbatch{2}.spm.tools.dartel.mni_norm.vox                = [NaN NaN NaN];
matlabbatch{2}.spm.tools.dartel.mni_norm.bb                 = [NaN NaN; NaN NaN; NaN NaN];
matlabbatch{2}.spm.tools.dartel.mni_norm.preserve           = 0;
matlabbatch{2}.spm.tools.dartel.mni_norm.fwhm               = [2 2 2];

% Create Warped Anatomical Images
matlabbatch{3}.spm.tools.dartel.crt_warped.flowfields(1)    = cfg_dep('Run Dartel (create Templates): Flow Fields', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '()',{':'})); % flowfield = deformation file. where to shrink tissue
matlabbatch{3}.spm.tools.dartel.crt_warped.images           = {rimgana};
matlabbatch{3}.spm.tools.dartel.crt_warped.jactransf        = 0;            % jacobian for inverse warp. 1 if I want inverse
matlabbatch{3}.spm.tools.dartel.crt_warped.K                = 6;
matlabbatch{3}.spm.tools.dartel.crt_warped.interp           = 7;            % 7th order bspline tradeoff computaional time

tic

spm_jobman('run',matlabbatch);
clear matlabbatch

toc

disp('Done')

end