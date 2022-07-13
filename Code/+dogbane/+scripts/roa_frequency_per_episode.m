tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa(tm);
% dogbane.guis.states(tm);
%%
roa_events = dogbane.tables.roa.roa_events(tm);

episodes = dogbane.tables.other.variable_to_table_rec_rig(tm,'state_episodes');
episodes(episodes.State == 'undefined',:) = [];
episodes = episodes(episodes.State == 'quiet',:);
episodes = episodes(episodes.genotype == 'wt_dual',:);

ts_info = dogbane.tables.other.ts_info(tm);

roa_events_per_ep = dogbane.table_processing.roa.roa_per_episode(roa_events,episodes,ts_info);
roa_events_per_ep.freq = roa_events_per_ep.freq * 60 * 100;
%%

tbl = table;
tbl.N_ep = height(roa_events_per_ep);
tbl.N_mice = length(unique(roa_events_per_ep.mouse));
tbl.N_trials = length(unique(roa_events_per_ep.trial));
tbl
file_name = '~/Desktop/sleep_project/freq_vs_episode_duration.xls';
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)
%%
mld = fitlm(roa_events_per_ep,'freq ~ StateDuration')
mld.plotAdded();
title('ROA frequency vs. quiet wakefulness episode duration');
ylabel('ROA frequency (events / min / 100umˆ2)');
xlabel('Quiet wake episode duration (s)');
set(gca,'FontSize',20);
set(gcf,'Position',[500,500,1000,600]);
begonia.path.make_dirs('~/Desktop/sleep_project/');
export_fig('~/Desktop/sleep_project/freq_vs_episode_duration.png');
export_fig('~/Desktop/sleep_project/freq_vs_episode_duration.fig');