begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('linescan_info'));

% Get labview trials. 
trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('start_time'));

%%
trial_times = trials.load_var('start_time');
trial_times = [trial_times{:}];

linescan_info = scans.load_var('linescan_info');
linescan_info = [linescan_info{:}];
scan_times = [linescan_info.start_time];
%%
[I_scans,I_trials] = begonia.util.align_timeinfo(scan_times,trial_times);
trials = trials(I_trials);
scans = scans(I_scans);

begonia.logging.log(1,'Saving links between linescans and recrig');
for i = 1:length(trials)
    trials(i).save_var('linescan',scans(i).uuid);
    scans(i).save_var('recrig',trials(i).uuid);
end

%% Export a table with the links
linescan_path = scans.load_var('path')';

linescan_info = scans.load_var('linescan_info');
linescan_info = [linescan_info{:}];
linescan_start = [linescan_info.start_time]';

linescan_duration = [linescan_info.duration]';

labview_path = trials.load_var('path')';

labview_start = trials.load_var('start_time');
labview_start = [labview_start{:}]';

labview_duration = trials.load_var('duration');
labview_duration = [labview_duration{:}]';

linescan_to_labview_delay = seconds(labview_start - linescan_start);

tbl = table(linescan_path,labview_path,linescan_start,labview_start,linescan_to_labview_delay,linescan_duration,labview_duration);

[~,I] = sort(labview_start,'descend');
tbl = tbl(I,:);

path = fullfile(eustoma.get_plot_path,'Linescan Tables','Trial Links','Linked Trials.csv');
begonia.util.save_table(path,tbl);

%% Make a table of linescans without link
scans = eustoma.get_linescans();
scans = scans(scans.has_var('linescan_info'));
scans = scans(~scans.has_var('recrig'));

linescan_path = scans.load_var('path')';

linescan_info = scans.load_var('linescan_info');
linescan_info = [linescan_info{:}];
linescan_start = [linescan_info.start_time]';

linescan_duration = [linescan_info.duration]';

tbl_scan_unlink = table(linescan_path,linescan_start,linescan_duration);

[~,I] = sort(linescan_start,'descend');
tbl_scan_unlink = tbl_scan_unlink(I,:);

path = fullfile(eustoma.get_plot_path,'Linescan Tables','Trial Links','Unlinked Linescans.csv');
begonia.util.save_table(path,tbl_scan_unlink);

%% Make a table of labview trials without link
trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('start_time'));
trials = trials(~trials.has_var('linescan'));
labview_path = trials.load_var('path')';

labview_start = trials.load_var('start_time');
labview_start = [labview_start{:}]';

labview_duration = trials.load_var('duration');
labview_duration = [labview_duration{:}]';

tbl_rig_unlink = table(labview_path,labview_start,labview_duration);

[~,I] = sort(labview_start,'descend');
tbl_rig_unlink = tbl_rig_unlink(I,:);

path = fullfile(eustoma.get_plot_path,'Linescan Tables','Trial Links','Unlinked Recrig.csv');
begonia.util.save_table(path,tbl_rig_unlink);

%%
begonia.logging.log(1,'Finished');


