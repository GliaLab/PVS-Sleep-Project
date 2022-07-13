begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('episodes'));

%%
for i = 1:length(scans)
    begonia.logging.log(1,"Scan %d/%d",i,length(scans));
    diameter_red_baseline = scans(i).load_var('diameter_red_baseline',[]);
    diameter_green_baseline = scans(i).load_var('diameter_green_baseline',[]);
    diameter_peri_baseline = scans(i).load_var('diameter_peri_baseline',[]);
    
    if ~isempty(diameter_red_baseline)
        fs = diameter_red_baseline.vessel_fs(1);
        t = (0:length(diameter_red_baseline.diameter{1})-1)' / fs;
        vessel_name = string(diameter_red_baseline.vessel_name);
    elseif ~isempty(diameter_green_baseline)
        fs = diameter_green_baseline.vessel_fs(1);
        t = (0:length(diameter_green_baseline.diameter{1})-1)' / fs;
        vessel_name = string(diameter_green_baseline.vessel_name);
    else
        continue;
    end
    
    if ~isempty(diameter_red_baseline)
        lumen = diameter_red_baseline.diameter{1}';
    else
        lumen = nan(size(t));
    end
    
    if ~isempty(diameter_green_baseline)
        endfoot = diameter_green_baseline.diameter{1}';
    else
        endfoot = nan(size(t));
    end
    
    if ~isempty(diameter_peri_baseline)
        peri = diameter_peri_baseline.diameter{1}';
    else
        peri = nan(size(t));
    end
    
    episodes = scans(i).load_var('episodes');
    state = begonia.util.catvec(length(t),1);
    for j = 1:height(episodes)
        st = round(episodes.state_start(j) * fs) + 1;
        en = round(episodes.state_end(j) * fs) + 1;
        if en > length(state)
            continue;
        end
        state(st:en) = episodes.state(j);
    end
    
    tbl = table(t,state,endfoot,lumen,peri);
    
    filename = fullfile(eustoma.get_plot_path, "Linescan Diameter Traces CSV", vessel_name + ".csv");
    begonia.path.make_dirs(filename);
    writetable(tbl,filename)
    
end
