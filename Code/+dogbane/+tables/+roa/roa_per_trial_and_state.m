function tbl = roa_per_trial_and_state(tm,state_variable)
if nargin < 2
    state_variable = 'state_episodes';
end

tbl = dogbane.tables.roa.roa_per_episode(tm,state_variable);

[G,trial,state] = findgroups(tbl.trial,tbl.state);

state_duration = splitapply(@sum,tbl.state_duration,G);

roa_freq = splitapply( ...
    @(x,w) sum(x.*w)/sum(w), ...
    tbl.roa_freq, ...
    tbl.state_duration, ...
    G);

roa_density = splitapply( ...
    @(x,w) sum(x.*w)/sum(w), ...
    tbl.roa_density, ...
    tbl.state_duration, ...
    G);

roa_count = splitapply( ...
    @sum, ...
    tbl.roa_count, ...
    G);

highpass_roa_freq = splitapply( ...
    @(x,w) sum(x.*w)/sum(w), ...
    tbl.highpass_roa_freq, ...
    tbl.state_duration, ...
    G);

highpass_roa_density = splitapply( ...
    @(x,w) sum(x.*w)/sum(w), ...
    tbl.highpass_roa_density, ...
    tbl.state_duration, ...
    G);

highpass_roa_count = splitapply( ...
    @sum, ...
    tbl.highpass_roa_count, ...
    G);

highpass_thresh_roa_freq = splitapply( ...
    @(x,w) sum(x.*w)/sum(w), ...
    tbl.highpass_thresh_roa_freq, ...
    tbl.state_duration, ...
    G);

highpass_thresh_roa_density = splitapply( ...
    @(x,w) sum(x.*w)/sum(w), ...
    tbl.highpass_thresh_roa_density, ...
    tbl.state_duration, ...
    G);

highpass_thresh_roa_count = splitapply( ...
    @sum, ...
    tbl.highpass_thresh_roa_count, ...
    G);

tbl = table(trial,state,state_duration, ...
    roa_freq,roa_density,roa_count, ...
    highpass_roa_freq,highpass_roa_density,highpass_roa_count, ...
    highpass_thresh_roa_freq,highpass_thresh_roa_density,highpass_thresh_roa_count);

tbl_ids = dogbane.tables.other.trial_ids(tm);
tbl = innerjoin(tbl_ids,tbl);

tbl_ts_data = dogbane.tables.other.tseries_metadata(tm);
tbl_ts_data = tbl_ts_data(:,{'ts_uuid','dx','dx_squared','optical_zoom'});
tbl = innerjoin(tbl,tbl_ts_data);

end

