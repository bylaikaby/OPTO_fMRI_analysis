function skullstrip(pathana,anaorig)
%% Inputs
% pathana   = path to anatomical data.
% anaorig    = anatomical file name.

%% Function
cd(pathana);
anatomy = strcat(pathana,'\',anaorig,',1');

c1      = strcat(pathana,'\','c1',anaorig,',1');
c2      = strcat(pathana,'\','c2',anaorig,',1');
c3      = strcat(pathana,'\','c3',anaorig,',1');

% create average probabitlity map out of c1, c2, c3 --> output called probmapavg
matlabbatch{1}.spm.util.imcalc.input            = {
    c1 
    c2 
    c3
    };
matlabbatch{1}.spm.util.imcalc.output           = 'probmapavg';
matlabbatch{1}.spm.util.imcalc.outdir           = {pathana};
matlabbatch{1}.spm.util.imcalc.expression       = '(i1+i2+i3)/3';
matlabbatch{1}.spm.util.imcalc.var              = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx     = 0;
matlabbatch{1}.spm.util.imcalc.options.mask     = 0;
matlabbatch{1}.spm.util.imcalc.options.interp   = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype    = 4;

tic
spm_jobman('run',matlabbatch);
clear matlabbatch

% substract probmapavg from rare to create skull stripped rare
outputnam   = strcat('probmapavg','.nii,1');
probmapavg  = fullfile(pathana,outputnam);
outputname  = strcat('ss',anaorig,',1');

matlabbatch{1}.spm.util.imcalc.input            = {
    anatomy 
    probmapavg
    };
matlabbatch{1}.spm.util.imcalc.output           = outputname;
matlabbatch{1}.spm.util.imcalc.outdir           = {pathana};
matlabbatch{1}.spm.util.imcalc.expression       = 'i1.*i2';
matlabbatch{1}.spm.util.imcalc.var              = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx     = 0;
matlabbatch{1}.spm.util.imcalc.options.mask     = 0;
matlabbatch{1}.spm.util.imcalc.options.interp   = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype    = 4;

spm_jobman('run',matlabbatch);
clear matlabbatch

toc

disp('Done')

end
