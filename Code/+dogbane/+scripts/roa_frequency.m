tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
dogbane.guis.roa(tm);
% dogbane.guis.states(tm);
%%
roa_events = dogbane.tables.roa.roa_events(tm);

episodes = dogbane.tables.other.variable_to_table_rec_rig(tm,'state_episodes');
episodes(episodes.State == 'undefined',:) = [];

ts_info = dogbane.tables.other.ts_info(tm);

%%
I = episodes.StateDuration > 10 & episodes.State == 'quiet';
episodes_short_quiet = episodes;
episodes_short_quiet(I,:) = [];

[G,tbl] = findgroups(episodes_short_quiet(:,{'genotype','State'}));
tbl.N_episodes = splitapply(@length,episodes_short_quiet.State,G);
file_name = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_v2_short_quiet/episodes.xls';
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)

roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events,episodes_short_quiet,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_v2_short_quiet';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all
%%
I = episodes.StateDuration <= 10 & episodes.State == 'quiet';
episodes_short_quiet = episodes;
episodes_short_quiet(I,:) = [];

[G,tbl] = findgroups(episodes_short_quiet(:,{'genotype','State'}));
tbl.N_episodes = splitapply(@length,episodes_short_quiet.State,G);
file_name = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_v2_long_quiet/episodes.xls';
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)

roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events,episodes_short_quiet,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_v2_long_quiet';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all
%%

[G,tbl] = findgroups(episodes(:,{'genotype','State'}));
tbl.N_episodes = splitapply(@length,episodes.State,G);
file_name = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_v2/episodes.xls';
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)

roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events,episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_v2';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all
%%
I = roa_events.roa_xy_size >= 1 & roa_events.roa_xy_size < 10;
roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events(I,:),episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_1_10';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all

I = roa_events.roa_xy_size >= 10 & roa_events.roa_xy_size < 100;
roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events(I,:),episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_10_100';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all

I = roa_events.roa_xy_size >= 100 & roa_events.roa_xy_size < 1000;
roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events(I,:),episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_100_1000';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all

I = roa_events.roa_xy_size >= 1000 & roa_events.roa_xy_size < 10000;
roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events(I,:),episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_1000_10000';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all

I = roa_events.roa_dur < 1;
roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events(I,:),episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_dur_0_1';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all

I = roa_events.roa_dur >= 1 & roa_events.roa_dur < 10;
roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events(I,:),episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_dur_1_10';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all

I = roa_events.roa_dur >= 10 & roa_events.roa_dur < 100;
roa_per_trial = dogbane.table_processing.roa.roa_per_trial(roa_events(I,:),episodes,ts_info);
output_folder = '~/Desktop/sleep_project/bar_plots/roa_frequency_per_state_dur_10_100';
dogbane.table_plots.roa.frequency_per_state_v2(roa_per_trial,output_folder);
close all