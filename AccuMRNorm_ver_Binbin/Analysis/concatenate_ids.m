function all_ids = concatenate_ids(fields)
    all_ids = [];  % Initialize an empty array
    field_names = fieldnames(fields);  % Get the names of all fields
    
    % Loop through each field and concatenate the arrays
    for i = 1:length(field_names)
        field_data = fields.(field_names{i});  % Extract data from each field
        all_ids = [all_ids, field_data];
        all_ids=sort(all_ids); 
        all_ids=unique(all_ids);
    end
end
