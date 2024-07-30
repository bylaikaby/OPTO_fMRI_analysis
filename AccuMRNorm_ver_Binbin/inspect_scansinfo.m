function inspect_scansinfo(par)
% Function to inspect information of specified EPIs
% Inputs:
%   - par: Parameter structure
%   - runIndices: Indices of the EPIs to inspect

% Check if there is more than one EPI to inspect

   

runIndices = 1:length(par.runs);



% Initialize variables to store the reference information
referenceInfo = [];
variedIndices = [];
is_varied = 0;
varied_count = 0;
subject_epis=[];
for i = 1:length(runIndices)
    index = runIndices(i);
    func = fullfile(par.runs(index).folder,par.runs(index).name);
    v_func = spm_vol(func);
    nimage = length(v_func);
    di = spm_imatrix(v_func(1).mat);
    epivox = abs(di(7:9));  % EPI voxel size
    tr=v_func(1).private.timing.tspace;
    formatSpec = 'EPI [%s] has [%d] images,TR [%ds] and voxel size [%g %g %g]\n';
     
    subject_epis(i).info=sprintf(formatSpec, par.runs(i).name, nimage, tr,epivox(:));


    % Store the information from the first EPI as reference
    if i == 1
        referenceInfo = {nimage, epivox(:)};
    else
        % Check if the current EPI's information matches the reference
        if ~isequal({nimage, epivox(:)}, referenceInfo)
            is_varied=1;
            varied_count = varied_count+ 1 ;
            variedIndices = [variedIndices,i];
            referenceInfo = {nimage, epivox(:)};
            
        end
    end
end
v_anat = spm_vol(par.ana);
    
di = spm_imatrix(v_anat.mat);

anavox = abs(di(7:9));
tr=v_anat.private.timing.tspace;% voxel size

formatSpec = 'ANAT [%s] has TR [%ds] and voxel size [%g %g %g]\n\n';
subject_ana=sprintf(formatSpec, par.anaorig, tr,anavox(:));


if is_varied ==1
    subject_epi_varied=sprintf('EPI information varies.');
else
    subject_epi_varied=sprintf('EPI information constant.');
end


subject=sprintf('For subject %s:\n',par.folder);
subject_info = [subject,subject_ana,subject_epis(:).info,subject_epi_varied];
display(subject_info);

end 