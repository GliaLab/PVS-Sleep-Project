function roa_stats_traces(trial)
ts = trial.tseries;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

ts.clear_var('roa_size_trace');
ts.clear_var('roa_volume_trace');
ts.clear_var('roa_duration_trace');

if ~ts.has_var('highpass_thresh_roa_table')
    return;
end
%%
tbl = ts.load_var('highpass_thresh_roa_table');
tbl.roa_dur = tbl.roa_t_end - tbl.roa_t_start;

dur = seconds(ts.duration);
N = round(dur*fs);

roa_size_trace = nan(N,1);
roa_volume_trace = nan(N,1);
roa_duration_trace = nan(N,1);

for i = 1:N
    I = tbl.roa_t_start_idx == i;
    roa_size_trace(i) = mean(tbl.roa_xy_size(I));
    roa_volume_trace(i) = mean(tbl.roa_vol_size(I));
    roa_duration_trace(i) = mean(tbl.roa_dur(I));
end

ts.save_var(roa_size_trace)
ts.save_var(roa_volume_trace)
ts.save_var(roa_duration_trace)
end

