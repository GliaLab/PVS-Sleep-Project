clear all

%% Load tseries
ts = get_tseries(true,"TSeries uncorrected");

%%
for i = 1:length(ts)
    iris.util.log_progress(i,ts,0,"Trial");
    iris.processing_functions.load_tseries_info(ts(i));
    iris.processing_functions.calc_channel_time_series(ts(i));
end
