begonia.logging.set_level(1);

ts = eustoma.get_sleep_tseries();
ts = ts(ts.has_var('path'));

trials = eustoma.get_sleep_recrig();
trials = trials(trials.has_var('path'));

%%
trial_times = trials.load_var('start_time');
trial_times = [trial_times{:}];

tseries_start = ts.load_var('start_time');
tseries_start = [tseries_start{:}];
%%
[I_trials,I_ts] = begonia.util.align_timeinfo(trial_times,tseries_start,'lag',seconds(15),'time_window',seconds(30));
trials = trials(I_trials);
ts = ts(I_ts);

begonia.logging.log(1,'Saving links between tseries and recrig');
for i = 1:length(trials)
    trials(i).save_var('tseries',ts(i).uuid);
    ts(i).save_var('recrig',trials(i).uuid);
end

%% Export a table with the links
tseries_path = ts.load_var('path')';

tseries_start = ts.load_var('start_time');
tseries_start = [tseries_start{:}]';

labview_path = trials.load_var('path')';

labview_start = trials.load_var('start_time');
labview_start = [labview_start{:}]';

tbl = table(tseries_path,tseries_start,labview_path,labview_start);

path = fullfile(eustoma.get_plot_path,'Sleep Project Tables','trial_links.csv');
begonia.util.save_table(path,tbl);

%%
begonia.logging.log(1,'Finished');


