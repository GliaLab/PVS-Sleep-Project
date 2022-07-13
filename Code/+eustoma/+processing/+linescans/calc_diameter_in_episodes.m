begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_green_baseline') | scans.has_var('diameter_red_baseline') | scans.has_var('diameter_peri_baseline'));
scans = scans(scans.has_var('episodes'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

%%
all_tbls = cell(length(scans),1);

for i = 1:length(scans)
    episodes = scans(i).load_var('episodes',[]);
    if isempty(episodes)
        continue;
    end
    N_episodes = height(episodes);
    
    diameter_green = scans(i).load_var('diameter_green_baseline',[]);
    diameter_red = scans(i).load_var('diameter_red_baseline',[]);
    diameter_peri = scans(i).load_var('diameter_peri_baseline',[]);
    
    % Get the sample groups.
    if isempty(diameter_red)
        N_vessels = height(diameter_green);
        fs = diameter_green.vessel_fs(1);
        
        genotype = repmat(diameter_green.genotype(1),N_episodes,1);
        mouse = repmat(diameter_green.mouse(1),N_episodes,1);
        date = repmat(diameter_green.date(1),N_episodes,1);
        trial_id = repmat(diameter_green.trial_id(1),N_episodes,1);
        vessel_type = repmat(diameter_green.vessel_type(1),N_episodes,1);
        vessel_name = repmat(diameter_green.vessel_name(1),N_episodes,1);
        vessel_id = repmat(diameter_green.vessel_id(1),N_episodes,1);
    else
        N_vessels = height(diameter_red);
        fs = diameter_red.vessel_fs(1);
        
        genotype = repmat(diameter_red.genotype(1),N_episodes,1);
        mouse = repmat(diameter_red.mouse(1),N_episodes,1);
        date = repmat(diameter_red.date(1),N_episodes,1);
        trial_id = repmat(diameter_red.trial_id(1),N_episodes,1);
        vessel_type = repmat(diameter_red.vessel_type(1),N_episodes,1);
        vessel_name = repmat(diameter_red.vessel_name(1),N_episodes,1);
        vessel_id = repmat(diameter_red.vessel_id(1),N_episodes,1);
    end
    
    tbls = cell(N_vessels,1);
    for  j = 1:N_vessels
        
        diam_green = nan(N_episodes,1);
        diam_red = nan(N_episodes,1);
        diam_peri = nan(N_episodes,1);
        
        diam_change_green = nan(N_episodes,1);
        diam_change_red = nan(N_episodes,1);
        diam_change_peri = nan(N_episodes,1);
        
        diam_ratio_change_green = nan(N_episodes,1);
        diam_ratio_change_red = nan(N_episodes,1);
        diam_ratio_change_peri = nan(N_episodes,1);
        
        area_change_green = nan(N_episodes,1);
        area_change_red = nan(N_episodes,1);
        area_change_peri = nan(N_episodes,1);
        
        area_ratio_change_green = nan(N_episodes,1);
        area_ratio_change_red = nan(N_episodes,1);
        area_ratio_change_peri = nan(N_episodes,1);
        
        for k = 1:N_episodes
            st = floor(episodes.state_start(k) * fs) + 1;
            en = floor(episodes.state_end(k) * fs) + 1;
            
            if ~isempty(diameter_green) && en <= length(diameter_green.diameter{j})
                trace = diameter_green.diameter{j}(st:en);
                
                diam_green(k) = nanmean(trace);
                diam_change_green(k) = nanmean(trace) - diameter_green.baseline(j);
                diam_ratio_change_green(k) = diam_change_green(k) / diameter_green.baseline(j);
                area_change_green(k) = pi * nanmean(trace.*trace - diameter_green.baseline(j) * diameter_green.baseline(j));
                area_ratio_change_green(k) = area_change_green(k) / diameter_green.baseline(j);
            end
            
            if ~isempty(diameter_red) && en <= length(diameter_red.diameter{j})
                trace = diameter_red.diameter{j}(st:en);
                
                diam_red(k) = nanmean(trace);
                diam_change_red(k) = nanmean(trace) - diameter_red.baseline(j);
                diam_ratio_change_red(k) = diam_change_red(k) / diameter_red.baseline(j);
                area_change_red(k) = pi * nanmean(trace.*trace - diameter_red.baseline(j) * diameter_red.baseline(j));
                area_ratio_change_red(k) = area_change_red(k) / diameter_red.baseline(j);
            end
            
            if ~isempty(diameter_peri) && en <= length(diameter_peri.diameter{j})
                trace = diameter_peri.diameter{j}(st:en);
                
                diam_peri(k) = nanmean(trace);
                diam_change_peri(k) = nanmean(trace) - diameter_peri.baseline(j);
                diam_ratio_change_peri(k) = diam_change_peri(k) / diameter_peri.baseline(j);
                area_change_peri(k) = pi * nanmean(trace.*trace - diameter_peri.baseline(j) * diameter_peri.baseline(j));
                area_ratio_change_peri(k) = area_change_peri(k) / diameter_peri.baseline(j);
            end
        end
        
        tbl = table(genotype,mouse,date,trial_id,vessel_type,vessel_name,vessel_id);
        tbl = [tbl,episodes];
        tbl.diameter_green = diam_green;
        tbl.diameter_red = diam_red;
        tbl.diameter_peri = diam_peri;
        tbl.diameter_change_green = diam_change_green;
        tbl.diameter_change_red = diam_change_red;
        tbl.diameter_change_peri = diam_change_peri;
        tbl.diameter_ratio_change_green = diam_ratio_change_green;
        tbl.diameter_ratio_change_red = diam_ratio_change_red;
        tbl.diameter_ratio_change_peri = diam_ratio_change_peri;
        tbl.area_change_red = area_change_red;
        tbl.area_change_green = area_change_green;
        tbl.area_change_peri = area_change_peri;
        tbl.area_ratio_change_red = area_ratio_change_red;
        tbl.area_ratio_change_green = area_ratio_change_green;
        tbl.area_ratio_change_peri = area_ratio_change_peri;
        
        % Trials without vessel_id can istead use the trial_id to represent
        % unique vessels. 
        I = tbl.vessel_id == "";
        tbl.vessel_id(I) = tbl.trial_id(I);
        tbls{j} = tbl;
    end
    
    diameter_in_episodes = cat(1,tbls{:});
    scans(i).save_var(diameter_in_episodes)
    
    all_tbls{i} = diameter_in_episodes;
end

big_table  = cat(1,all_tbls{:});

[~,I] = sort(string(big_table.vessel_name));
big_table = big_table(I,:);
tbl_path = fullfile(eustoma.get_plot_path,'Linescan Tables','Diameter in Episodes.csv');
begonia.util.save_table(tbl_path,big_table);
begonia.logging.log(1,'Finished');
