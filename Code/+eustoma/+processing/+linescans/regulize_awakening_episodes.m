begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('awakening_episodes'));

awakening_episodes = scans.load_var('awakening_episodes');
awakening_episodes = cat(1,awakening_episodes{:});
%%
figure;
histogram(awakening_episodes.ep_end-awakening_episodes.ep_start, "BinWidth", 1);

%%

for i = 1:length(scans)
    awakening_episodes = scans(i).load_var('awakening_episodes');
    dur = awakening_episodes.ep_end - awakening_episodes.ep_start;
    awakening_episodes(dur < 10, :) = [];
    
    awakening_episodes.ep_end = awakening_episodes.ep_start + 10;
    
    if isempty(awakening_episodes)
        scans(i).clear_var('awakening_episodes');
    else
        scans(i).save_var('awakening_episodes');
    end
end