function calc_channel_time_series(ts)

trial_id = ts.load_var("trial_id");
trial_id = string(trial_id);
    
channel_time_series = table;
channel_time_series.trial_id = repmat(trial_id, ts.channels, 1);

for ch = 1:ts.channels
    y = ts.get_mat(ch);
    y = y(:,:,:);
    y = mean(mean(y,1),2);
    y = reshape(y,1,[]);
    
    x = (0:length(y)-1) * ts.dt;
    
    channel_time_series.x(ch) = {x};
    channel_time_series.y(ch) = {y};
    channel_time_series.fs(ch) = 1 / ts.dt;
    channel_time_series.ylabel(ch) = "Fluorescence (a.u.)";
    channel_time_series.name(ch) = sprintf("Fluorescence of channel %d", ch);
end

ts.save_var(channel_time_series);
end

