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

tbl_micro = dogbane.tables.other.variable_to_table_rec_rig(tm,'microarousals');
tbl_micro = tbl_micro(tbl_micro.state == 'microarousal',:);

% Merge episodes and with microarousals
trial = [episodes.trial;tbl_micro.trial];
State = [episodes.State;tbl_micro.state];
StateStart = [episodes.StateStart;tbl_micro.state_start];
StateEnd = [episodes.StateEnd;tbl_micro.state_end];
StateDuration = [episodes.StateDuration;tbl_micro.state_duration];

episodes = table(trial,State,StateStart,StateEnd,StateDuration);

trial_ids = dogbane.tables.other.trial_ids(tm);

episodes = innerjoin(trial_ids,episodes);

roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events,episodes,ts_info);
%%
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_microarousals';
dogbane.table_plots.roa.frequency_per_state_micro(roa_per_trial,output_folder);
close all