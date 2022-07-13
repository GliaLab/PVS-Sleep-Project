function tbl = events_per_trial_and_state(tm)

tbl = dogbane.tables.aqua.events_per_episode(tm);

[G,trial,state] = findgroups(tbl.trial,tbl.state);

state_duration = splitapply(@sum,tbl.state_duration,G);

freq = splitapply( ...
    @(x,w) sum(x.*w)/sum(w), ...
    tbl.freq, ...
    tbl.state_duration, ...
    G);

event_count = splitapply( ...
    @sum, ...
    tbl.event_count, ...
    G);

tbl = table(trial,state,state_duration, ...
    freq,event_count);

tbl_ids = dogbane.tables.other.trial_ids(tm);
tbl = innerjoin(tbl_ids,tbl);

tbl_ts_data = dogbane.tables.other.tseries_metadata(tm);
tbl_ts_data = tbl_ts_data(:,{'ts_uuid','dx','dx_squared','optical_zoom'});
tbl = innerjoin(tbl,tbl_ts_data);

end

