
begonia.logging.set_level(1);

trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('sleep_episodes'));

for i = 1:length(trials)
    sleep_episodes = trials(i).load_var('sleep_episodes');
    I = sleep_episodes.state_end < 0;
    if any(I)
        begonia.logging.log(1,"Dirty sleep episodees in " + trials(i).load_var('path'));
    end
    sleep_episodes(I,:) = [];
    
    I = sleep_episodes.state_start < 0;
    if any(I)
        begonia.logging.log(1,"Dirty sleep episodees in " + trials(i).load_var('path'));
    end
    sleep_episodes.state_start(I) = 0;
    
    sleep_episodes.state_duration = sleep_episodes.state_end - sleep_episodes.state_start;
    
    trials(i).save_var(sleep_episodes);
end
