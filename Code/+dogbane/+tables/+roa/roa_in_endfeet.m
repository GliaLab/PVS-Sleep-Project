function tbl = roa_in_endfeet(tm)
tbl = dogbane.tables.variable_to_table_tseries(tm,'roa_in_endfeet_states',true);

% Calculate data per trial
[G,genotype,experiment,mouse,trial,state,roi_group] = findgroups( ...
    tbl.genotype, ...
    tbl.experiment, ...
    tbl.mouse, ...
    tbl.trial, ...
    tbl.state, ...
    tbl.roi_group);

roa_freq = splitapply(@(x,w) sum(x.*w)/sum(w),tbl.roa_freq,tbl.state_duration,G);
roa_density = splitapply(@(x,w) sum(x.*w)/sum(w),tbl.roa_freq,tbl.state_duration,G);

tbl = table(genotype,experiment,mouse,trial,state,roi_group,roa_freq,roa_density);

tbl_ts_data = dogbane.tables.tseries_metadata(tm);
tbl_ts_data = tbl_ts_data(:,{'trial','dx_squared'});
tbl = innerjoin(tbl,tbl_ts_data);

end

