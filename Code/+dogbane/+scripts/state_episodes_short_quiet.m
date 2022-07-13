tbl_episodes_short_quiet = dogbane.tables.other.variable_to_table_rec_rig(tm,'state_episodes_short_quiet',true);

I = tbl_episodes_short_quiet.State == 'quiet';
tbl = table;
tbl.N_ep = height(tbl_episodes_short_quiet(I,:));
tbl.N_mice = length(unique(tbl_episodes_short_quiet.mouse(I)));
tbl.N_trials = length(unique(tbl_episodes_short_quiet.trial(I)));
tbl
file_name = '~/Desktop/sleep_project/state_histograms/quiet_bout_durations.xls';
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)
%%
figure
I = tbl_episodes_short_quiet.State == 'quiet';
histogram(tbl_episodes_short_quiet.StateDuration(I),'BinWidth',1);
ylabel('# Episodes');
xlabel('Episode Duration (s)');
title('Quiet wakefulness episodes')
set(gca,'FontSize',20);

output_folder = '~/Desktop/sleep_project/state_histograms';
begonia.path.make_dirs(output_folder);
file_name = fullfile(output_folder,'quiet_bout_durations_1.png');
export_fig(file_name);
file_name = fullfile(output_folder,'quiet_bout_durations_1.fig');
export_fig(file_name);

xlim([0,50]);
output_folder = '~/Desktop/sleep_project/state_histograms';
begonia.path.make_dirs(output_folder);
file_name = fullfile(output_folder,'quiet_bout_durations_2.png');
export_fig(file_name);
file_name = fullfile(output_folder,'quiet_bout_durations_2.fig');
export_fig(file_name);