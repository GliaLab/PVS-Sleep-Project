function load_tseries_info(ts)

ts_metadata = ts.read_metadata();
ts.save_var(ts_metadata);

% Make a trial ID based on the file location of the TSeries.
trial_id = iris.util.get_trial_name(ts);
% Save the ID for tseries.
ts.save_var(trial_id);

end

