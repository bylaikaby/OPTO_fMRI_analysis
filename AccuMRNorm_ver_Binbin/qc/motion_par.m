function motion_par (par)

%%

sessions = par.runs;
session_dir = par.pathepi;
session_names = par.runs;
outputdir = fullfile(par.work_dir,'preprocessing');

    
figure
for session = 1:length(sessions)
    fprintf('Processing session %d ...',session)
    session_names(session).name
    
    % load the raw functional images and calculate the global mean and pairwise variance
    v_all = spm_vol(fullfile(session_dir,[session_names(session).name]));
    
    clear a dt
    
    for imagei = 1:length(v_all)
        v = spm_vol(fullfile(session_dir, [session_names(session).name,',' num2str(imagei)]));
        y = spm_read_vols(v);
        
        a(:,imagei) = y(:);
    end
    
    gm = mean(mean(a)); % grand mean (4D)
    
    % calculate pairwise variance
    for imagei = 1:length(v_all)-1
        dt(imagei) = (mean((a(:,imagei) - a(:,imagei+1)).^2))/gm;
    end
    
    meany = mean(a)./gm; % scaled global mean
   

    
    % load rigid body motion parameters and calculate framewise displacement 
    rp = load(fullfile(session_dir,['rp_',erase(session_names(session).name,'.nii'),'.txt']));

    fd_trans = fd_calc(rp(:,1:3));
    fd_rotat = fd_calc(rp(:,4:6)*180/pi);
    
    fd_max_trans(session,1) = max(fd_trans);
    fd_max_rotat(session,1) = max(fd_rotat);
    
    fd_mean_trans(session,1) = mean(fd_trans);
    fd_mean_rotat(session,1) = mean(fd_rotat);
    
    
 
    % plots
    subplot(2,2,1)
    plot(meany)
    title('Global mean (raw)');xlabel('Image number')
    box off
    
    subplot(2,2,3)
    plot(dt)
    yline(mean(dt)+3*std(dt),'-','3 SD','color',[0 0.4470 0.7410]);
    title('Pairwise variance (raw)');xlabel('Image pair')
    box off
    
    subplot(2,2,2)
    plot([rp(:,1:3) rp(:,4:6)*180/pi])
    title('Rigid body motion');xlabel('Image number')
    box off
    
    subplot(2,2,4)
    plot([fd_trans fd_rotat])
    title('Framewise displacement');xlabel('Image pair')
    legend('Translation','Rotation','location','best','box','off')
    if max(max([fd_trans fd_rotat])) > 1.5
        yline(1.5,'r','FD = 1.5');
    end
    box off
    
    exportgraphics(gcf,[outputdir,'\',session_names(session).name '.jpg']);
    
    fprintf('done!\n')
end



included = find(fd_max_trans<1.5&fd_max_rotat<1.5);
excluded = find(fd_max_trans>1.5|fd_max_rotat>1.5);

par.runs(excluded).name


end 