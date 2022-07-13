begonia.logging.set_level(1);

ts = eustoma.get_sleep_tseries(true);

%%

I = [ts.channels] == 2;
ts_n = ts(I);

%%

mat = ts_n(randi(length(ts_n))).get_mat(2);
mat = begonia.util.stepping_window(mat,10);

%%
yucca.plot.matview(mat,[0,4000]);