begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('recrig'));
scans = scans(scans.has_var('trial_id'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);
%%
for i = 1:length(scans)
    sleep_episodes = scans(i).find_dnode('recrig').load_var('sleep_episodes',[]);
    
    baseline_episodes = scans(i).load_var('baseline_episodes',[]);
    
    wakefulness_episodes = scans(i).find_dnode('recrig').load_var('wakefulness_episodes',[]);
    
    awakening_episodes = scans(i).load_var('awakening_episodes',[]);
    if ~isempty(awakening_episodes)
        awakening_episodes.state = awakening_episodes.ep;
        awakening_episodes.state_start = awakening_episodes.ep_start;
        awakening_episodes.state_end = awakening_episodes.ep_end;
        awakening_episodes.state_duration = awakening_episodes.state_end - awakening_episodes.state_start;
        awakening_episodes.ep = [];
        awakening_episodes.genotype = [];
        awakening_episodes.ep_start = [];
        awakening_episodes.ep_end = [];
        awakening_episodes.ep_id = [];
    end
    
    episodes = cat(1,sleep_episodes,baseline_episodes,wakefulness_episodes,awakening_episodes);
    
    if isempty(episodes)
        continue;
    end
    
    %%
    trial_id = scans(i).load_var('trial_id');
    
    episodes.episode_id = repmat("", height(episodes),1);
    for j = 1:height(episodes)
        episodes.episode_id(j) = sprintf("%s Ep. #%.f",trial_id.trial_id, j);
    end
    
    % Convert all state names to string. There was a problem that some
    % where categorical and some were string.
    episodes.state = string(episodes.state);
    
    scans(i).save_var(episodes);
end