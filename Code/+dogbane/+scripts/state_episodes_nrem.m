tbl_episodes = dogbane.tables.other.variable_to_table_rec_rig(tm,'state_episodes',true);
%%
figure
I = tbl_episodes.State == 'nrem';
histogram(tbl_episodes.StateDuration(I),'BinWidth',1);
ylabel('# Episodes');
xlabel('Episode Duration (s)');
title('NREM episodes')
set(gca,'FontSize',20);

output_folder = '~/Desktop/sleep_project/state_histograms';
begonia.path.make_dirs(output_folder);
file_name = fullfile(output_folder,'nrem_bout_durations_1.png');
export_fig(file_name);
file_name = fullfile(output_folder,'nrem_bout_durations_1.fig');
export_fig(file_name);

xlim([0,50]);
output_folder = '~/Desktop/sleep_project/state_histograms';
begonia.path.make_dirs(output_folder);
file_name = fullfile(output_folder,'quiet_bout_durations_2.png');
export_fig(file_name);
file_name = fullfile(output_folder,'quiet_bout_durations_2.fig');
export_fig(file_name);