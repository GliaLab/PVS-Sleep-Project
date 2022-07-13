begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('pulsatility_green') | scans.has_var('pulsatility_red'));
scans = scans(scans.has_var('recrig'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

%%
all_tbls = cell(length(scans),1);

for i = 1:length(scans)
    sleep_episodes = scans(i).find_dnode('recrig').load_var('sleep_episodes',[]);
    if isempty(sleep_episodes)
        continue;
    end
    N_episodeds = height(sleep_episodes);
    
    puls_green = scans(i).load_var('pulsatility_green',[]);
    puls_red = scans(i).load_var('pulsatility_red',[]);
    if isempty(puls_red)
        N_vessels = height(puls_green);
        fs = puls_green.vessel_fs(1);
        
        genotype = repmat(puls_green.genotype(1),N_episodeds,1);
        mouse = repmat(puls_green.mouse(1),N_episodeds,1);
        date = repmat(puls_green.date(1),N_episodeds,1);
        trial_id = repmat(puls_green.trial_id(1),N_episodeds,1);
        vessel_type = repmat(puls_green.vessel_type(1),N_episodeds,1);
        vessel_name = repmat(puls_green.vessel_name(1),N_episodeds,1);
    else
        N_vessels = height(puls_red);
        fs = puls_red.vessel_fs(1);
        
        genotype = repmat(puls_red.genotype(1),N_episodeds,1);
        mouse = repmat(puls_red.mouse(1),N_episodeds,1);
        date = repmat(puls_red.date(1),N_episodeds,1);
        trial_id = repmat(puls_red.trial_id(1),N_episodeds,1);
        vessel_type = repmat(puls_red.vessel_type(1),N_episodeds,1);
        vessel_name = repmat(puls_red.vessel_name(1),N_episodeds,1);
    end
    
    tbls = cell(N_vessels,1);
    for  j = 1:N_vessels
        
        pulsatility_green = nan(N_episodeds,1);
        pulsatility_red = nan(N_episodeds,1);
        
        for k = 1:N_episodeds
            st = floor(sleep_episodes.state_start(k) * fs) + 1;
            en = floor(sleep_episodes.state_end(k) * fs) + 1;
            
            if isempty(puls_green) || en > length(puls_green.pulsatility{j})
                trace_green = nan;
            else
                trace_green = puls_green.pulsatility{j}(st:en);
            end
            % Multiply by 3000 ms to match Iliff metric.
            pulsatility_green(k) = nanmean(abs(trace_green)) * 3000;
            
            if isempty(puls_red) || en > length(puls_red.pulsatility{j})
                trace_red = nan;
            else
                trace_red = puls_red.pulsatility{j}(st:en);
            end
            % Multiply by 3000 ms to match Iliff metric.
            pulsatility_red(k) = nanmean(abs(trace_red)) * 3000;
            
        end
        
        tbl = table(genotype,mouse,date,trial_id,vessel_type,vessel_name);
        tbl = [tbl,sleep_episodes];
        tbl.pulsatility_green = pulsatility_green;
        tbl.pulsatility_red = pulsatility_red;
        tbls{j} = tbl;
    end
    
    pulsatility_in_sleep = cat(1,tbls{:});
    scans(i).save_var(pulsatility_in_sleep)
    
    all_tbls{i} = pulsatility_in_sleep;
end

big_table  = cat(1,all_tbls{:});

[~,I] = sort(string(big_table.vessel_name));
big_table = big_table(I,:);
tbl_path = fullfile(eustoma.get_plot_path,'Linescan Tables','Pulsatility in Sleep.csv');
begonia.util.save_table(tbl_path,big_table);
begonia.logging.log(1,'Finished');
