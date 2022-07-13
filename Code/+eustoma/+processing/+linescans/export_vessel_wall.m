begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('clean_episodes') | scans.has_var('awakening_episodes') | scans.has_var('episodes'));
scans = scans(scans.has_var('vessel_wall'));

%%
for i = 1:length(scans)
    begonia.logging.log(1,"Scan %d/%d",i,length(scans));
    vessel_wall = scans(i).load_var('vessel_wall');

    fs = vessel_wall.vessel_fs(1);
    vessel_name = string(vessel_wall.vessel_name);
    
    % If the vessel name does not contain the a vessel number instead
    % insert a default value of 000. This is to simplify loading the traces 
    % in python.
    if ~vessel_name.endsWith(digitsPattern)
        vessel_name = vessel_name + " 000";
    end
    
    endfoot_upper = vessel_wall.endfoot_upper{1}';
    endfoot_lower = vessel_wall.endfoot_lower{1}';
    lumen_upper = vessel_wall.lumen_upper{1}';
    lumen_lower = vessel_wall.lumen_lower{1}';
    t = vessel_wall.time{1}';
    
    % Include awakenings as well as clean episodes.
    episodes = scans(i).load_var('clean_episodes', table);
    awakening_episodes = scans(i).load_var("awakening_episodes",[]);
    if ~isempty(awakening_episodes)
        awakening_episodes.genotype = [];
        episodes = cat(1,episodes,awakening_episodes);
    end
    if ~isempty(episodes)
        state = begonia.util.catvec(length(t),1);
        for j = 1:height(episodes)
            st = round(episodes.ep_start(j) * fs) + 1;
            en = round(episodes.ep_end(j) * fs) + 1;
            if en > length(state)
                continue;
            end
            state(st:en) = episodes.ep(j);
        end
        tbl = table(t,state,endfoot_upper,endfoot_lower,lumen_upper,lumen_lower);
        filename = fullfile(eustoma.get_plot_path, "Vessel Wall CSV Clean + Awakening", vessel_name + ".csv");
        begonia.path.make_dirs(filename);
        writetable(tbl,filename)
    end
    
    % Include awakenings as well as clean episodes.
    episodes = scans(i).load_var('episodes', table);
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
        tbl = table(t,state,endfoot_upper,endfoot_lower,lumen_upper,lumen_lower);
        filename = fullfile(eustoma.get_plot_path, "Vessel Wall CSV", vessel_name + ".csv");
        begonia.path.make_dirs(filename);
        writetable(tbl,filename)
    end
end
