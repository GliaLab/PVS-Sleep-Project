begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('awakening_episodes') | scans.has_var('episodes'));
scans = scans(scans.has_var('vessel_wall_red'));

%%
for i = 1:length(scans)
    begonia.logging.log(1,"Scan %d/%d",i,length(scans));
    vessel_wall_red = scans(i).load_var('vessel_wall_red');

    fs = vessel_wall_red.vessel_fs(1);
    vessel_name = string(vessel_wall_red.vessel_name);
    
    % If the vessel name does not contain the a vessel number instead
    % insert a default value of 000. This is to simplify loading the traces 
    % in python.
    if ~vessel_name.endsWith(digitsPattern)
        vessel_name = vessel_name + " 000";
    end
    
    lumen_upper = vessel_wall_red.lumen_upper{1}';
    lumen_lower = vessel_wall_red.lumen_lower{1}';
    t = vessel_wall_red.time{1}';
    
    % Import awakening.
    awakening_episodes = scans(i).load_var("awakening_episodes",[]);
    if ~isempty(awakening_episodes)
        state = begonia.util.catvec(length(t),1);
        for j = 1:height(awakening_episodes)
            st = round(awakening_episodes.ep_start(j) * fs) + 1;
            en = round(awakening_episodes.ep_end(j) * fs) + 1;
            if en > length(state)
                continue;
            end
            state(st:en) = awakening_episodes.ep(j);
        end
    
        % Export clean episodes.
        tbl = table(t,state,lumen_upper,lumen_lower);
        filename = fullfile(eustoma.get_plot_path, "Lumen Vessel Wall CSV Awakening", vessel_name + ".csv");
        begonia.path.make_dirs(filename);
        writetable(tbl,filename);
    end

    % Import "unclean" episodes.
    episodes = scans(i).load_var('episodes',[]);
    if ~isempty(episodes)
        state = begonia.util.catvec(length(t),1);
        for j = 1:height(episodes)
            st = round(episodes.state_start(j) * fs) + 1;
            en = round(episodes.state_end(j) * fs) + 1;
            if en > length(state)
                continue;
            end
            state(st:en) = episodes.state(j);
        end
    
        % Export clean episodes.
        tbl = table(t,state,lumen_upper,lumen_lower);
        filename = fullfile(eustoma.get_plot_path, "Lumen Vessel Wall CSV", vessel_name + ".csv");
        begonia.path.make_dirs(filename);
        writetable(tbl,filename);
    end
end
