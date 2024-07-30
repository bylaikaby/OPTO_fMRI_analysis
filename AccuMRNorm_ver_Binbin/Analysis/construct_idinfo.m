function subject_idinfo = construct_idinfo(subjectID, IDs,taskName, position)
   

% setup necessary ids for the model, groupIds are the ids of the RUN of
% interest of this model.



% Concatenate run IDs for OPTO and MSTIM
    runIds = [concatenate_ids(IDs.OPTO), concatenate_ids(IDs.MSTIM)];
    
    % Define group IDs and other fields
    
    switch taskName
        case "OPTO"
            groupIds = IDs.OPTO.(position);
        case "MSTIM"
            groupIds = IDs.MSTIM.(position);
        case "OPTO+MSTIM"
            groupIds = [IDs.OPTO.(position), IDs.MSTIM.(position)];
        otherwise
            error('Invalid task name specified.');
    end

    optoIds = concatenate_ids(IDs.OPTO);
    mstimIds = concatenate_ids(IDs.MSTIM);
    
    % Construct the subject_idinfo structure
    subject_idinfo = struct(...
        'subjectID', subjectID, ...
        'runIds', runIds, ...
        'groupIds', groupIds, ...
        'optoIds', optoIds, ...
        'mstimIds', mstimIds ...
    );
end
