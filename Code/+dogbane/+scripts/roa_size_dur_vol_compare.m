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

ts_info = dogbane.tables.other.ts_info(tm);

roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events,episodes,ts_info);
%%
dogbane.table_plots.roa.size_per_state(roa_per_trial);
dogbane.table_plots.roa.duration_per_state(roa_per_trial);
dogbane.table_plots.roa.volume_per_state(roa_per_trial);