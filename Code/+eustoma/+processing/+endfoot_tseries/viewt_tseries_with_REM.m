clear all 
begonia.logging.set_level(1);

ts = eustoma.get_endfoot_tseries(true);
ts = ts(ts.has_var("rem"));
ts = ts(ts.has_var("vessel_position"));
%%
close all force
dataman.start(ts);