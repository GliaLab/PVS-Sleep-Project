begonia.logging.set_level(1);
rr = eustoma.get_endfoot_recrigs();
ts = eustoma.get_endfoot_tseries();
%%
rr_times = rr.load_var('start_time');
rr_times = [rr_times{:}];

ts_times = ts.load_var('start_time');
ts_times = [ts_times{:}];
%%
[I_rr,I_ts] = begonia.util.align_timeinfo(rr_times,ts_times);
rr = rr(I_rr);
ts = ts(I_ts);

begonia.logging.log(1,'Saving links between endfoot tseries and recrig');
for i = 1:length(rr)
    rr(i).save_var('tseries',ts(i).uuid);
    ts(i).save_var('recrig',rr(i).uuid);
end
begonia.logging.log(1,'Finished');


