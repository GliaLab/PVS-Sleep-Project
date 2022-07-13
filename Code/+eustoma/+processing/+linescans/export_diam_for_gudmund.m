clear all
%%
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('clean_episodes'));
scans = scans(scans.has_var('diameter_red_baseline'));
scans = scans(scans.has_var('diameter_green_baseline'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);
%% 
% First we gave Gudmund these 4 trials, later we gave all clean trials.
selected_trials = ["WT 08 20210309 03", "WT 08 20210311 06", ...
    "WT 08 20210311 10", "WT 09 20210308 03"];
trial_ids = "";
for i = 1:length(scans)
    trial_id = scans(i).load_var('trial_id');
    trial_ids(i) = trial_id.trial_id;
end
I = ismember(trial_ids, selected_trials);
% Instead of selecting only 4 trials, just assert that these old trials are
% in the new dataset we sent him. 
assert(sum(I) == length(selected_trials));
% scans = scans(I);

%%
color_table = eustoma.processing.linescans.get_sleep_color_table();
color_table.ep_name(color_table.ep_name == "Locomotion") = "Clean Locomotion";
color_table.ep_name(color_table.ep_name == "Whisking") = "Clean Whisking";
color_table.ep_name(color_table.ep_name == "Quiet") = "Clean Quiet";
color_table.ep_name(color_table.ep_name == "Awakening") = "Clean Awakening";
color_table.ep_name(color_table.ep_name == "REM") = "Clean REM";
color_table.ep_name(color_table.ep_name == "NREM") = "Clean NREM";
color_table.ep_name(color_table.ep_name == "IS") = "Clean IS";
color_table.ep_name(color_table.ep_name == "Vessel Baseline") = "Clean Vessel Baseline";

%%
for i = 1:length(scans)
    diameter_red_baseline = scans(i).load_var('diameter_red_baseline');
    diameter_green_baseline = scans(i).load_var('diameter_green_baseline');
    clean_episodes = scans(i).load_var('clean_episodes');
    
    fs = diameter_green_baseline.vessel_fs(1);
    
    t = (0:length(diameter_green_baseline.diameter{1})-1)' / fs;
    endfoot = diameter_green_baseline.diameter{1}';
    lumen = diameter_red_baseline.diameter{1}';
    
    vessel_name = string(diameter_red_baseline.vessel_name(1));
    
    clean_episodes(clean_episodes.ep == "Clean Vessel Baseline",:) = [];
    %% Save ECoG and EMG.
    
    ephys = scans(i).find_dnode("recrig").load_var('ephys');
    
    state = begonia.util.catvec(height(ephys), 1);
    for j = 1:height(clean_episodes)
        st = round(clean_episodes.ep_start(j) * ephys.Properties.SampleRate) + 1;
        en = round(clean_episodes.ep_end(j) * ephys.Properties.SampleRate) + 1;
        
        if en > length(state)
            break;
        end
        
        state(st:en) = clean_episodes.ep(j);
    end
    
    
    tbl = table;
    tbl.t = seconds(ephys.Time);
    tbl.ecog = ephys.ecog;
    tbl.emg = ephys.emg;
    tbl.state = state;
    
    filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Traces for Gudmund",vessel_name + " ECoG, EMG and sleep.csv");
    begonia.path.make_dirs(filename);
    writetable(tbl,filename);
    %%
    % Plot ECoG and EMG
    f = figure;
    tile = tiledlayout(2,1);
    
    nexttile;
    plot(ephys.Time,ephys.ecog);
    title("ECoG raw signal")
    if ~isempty(clean_episodes)
        yucca.plot.plot_episodes( ...
            clean_episodes.ep, ...
            clean_episodes.ep_start, ...
            clean_episodes.ep_end,0.3,[],color_table);
    end
    
    nexttile;
    plot(ephys.Time,ephys.emg);
    title("EMG raw signal")
    if ~isempty(clean_episodes)
        yucca.plot.plot_episodes( ...
            clean_episodes.ep, ...
            clean_episodes.ep_start, ...
            clean_episodes.ep_end,0.3,[],color_table);
    end
    
    filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Traces for Gudmund",vessel_name + " ECoG, EMG and sleep.png");
    exportgraphics(f,filename)
    close(f);
    
    %%
    state = begonia.util.catvec(length(t),1);
    for j = 1:height(clean_episodes)
        st = round(clean_episodes.ep_start(j) * fs) + 1;
        en = round(clean_episodes.ep_end(j) * fs) + 1;
        
        if en > length(state)
            break;
        end
        
        state(st:en) = clean_episodes.ep(j);
    end
    
    tbl = table(t,state,endfoot,lumen);
    
    filename = fullfile(eustoma.get_plot_path,"Linescan Diameter Traces for Gudmund",diameter_red_baseline.trial_id(1)+" diameter.csv");
    begonia.path.make_dirs(filename);
    writetable(tbl,filename);
    
end
