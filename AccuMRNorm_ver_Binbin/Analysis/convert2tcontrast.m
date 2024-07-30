function numericValues = convert2tcontrast(strings,categories,contrast)
    % mapSpecialStrings Maps specific strings to predefined numeric values.
    %
    % Input:
    %   strings - Cell array of strings to be mapped.
    % categories - conditions
    %   contrast - coresponding contrast assigned to the categories
    %
    % Output:
    %   numericValues - Array of numbers where 'BLANK_pre' and 'BLANK_post' map to 0,
    %                   and 'STIM' maps to 1.
    if isstring(strings)
        strings = cellstr(strings); % Convert string array to cell array of strings
    end

    % Define the unique categories and their corresponding numbers
    categories = {'BLANK_pre', 'STIM', 'BLANK_post'};
    numbers = [0, 1, 0];

    % Find the index of each string in the 'categories' array
    [~, idx] = ismember(strings, categories);

    % Map the indices to the corresponding numbers
    numericValues = numbers(idx);
end
