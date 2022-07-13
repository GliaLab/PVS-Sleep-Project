clear all

%% Load tseries
ts = get_tseries(true);
ts = ts(ts.has_var("trial_id"));

%%
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    iris.processing_functions.calc_channel_time_series(ts(i));
end
