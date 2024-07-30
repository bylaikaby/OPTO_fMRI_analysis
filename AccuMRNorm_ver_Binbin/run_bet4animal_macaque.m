%% Function to run bet4animal using WSL through Matlab




function run_bet4animal_macaque(fslpath, input, outputdir,threshold)



    % Convert Windows paths to Linux paths

    input = convert2LinuxPath(input);
    outputdir = convert2LinuxPath(outputdir);

    betpath = fullfile(fslpath, 'bin/bet4animal_wsl');
    betpath= convert2LinuxPath(betpath);

    [~, fname, ext] = fileparts(input);

    % Convert output path to Linux path
    output = strcat(outputdir, '/', fname, '_BETss', ext);
    
    animal_choice = '-z 2'; %corresponding to macaque

    if nargin < 4 || isempty(threshold)
        threshold = '';
    else
        threhold_display = threshold
        threshold = ['-f ', num2str(threshold)];
        
    end

    cmdarray = {'wsl', betpath, input, output,threshold,'-z 2' };

    cmd = strjoin(string(cmdarray), ' ');

    status = system(cmd);

    % Check the status to see if the command ran successfully
    if status == 0
        formatSpec = 'Bet4animal executed successfully using WSL with threshold %g \n';
        fprintf (formatSpec,threhold_display)
    else
        disp('Error running bet4animal using WSL');
    end

    jsondesc = 'Anatomical scan skull-stripped using bet4animal_wsl';
    jsonsource = strcat('bids:raw:', fname, ext);
    jsoninfo = struct('Description', jsondesc, 'Sources', jsonsource);
    jsonstr = jsonencode(jsoninfo);

    % Convert output path to Windows path for JSON file
    jsonname = strcat(outputdir, '\', fname, '_BETss.json');
    jsonname = convert2WindowsPath(jsonname);

    fid = fopen(jsonname, 'w');
    fprintf(fid, jsonstr);
    fclose(fid);
    output=convert2WindowsPath(output);
    assignin('base', 'ss_anat', output);
end

function linuxPath = convert2LinuxPath(windowsPath)
    % Convert Windows path to Linux path
    linuxPath = strrep(windowsPath, '\', '/');
    linuxPath = strrep(linuxPath, 'D:/', '/mnt/d/');
    % Add other conversions as needed
end

function windowsPath = convert2WindowsPath(linuxPath)
    % Convert Linux path to Windows path
    windowsPath = strrep(linuxPath, '/mnt/d/', 'D:\');
    windowsPath =strrep(windowsPath, '/', '\')
    % Add other conversions as needed
end