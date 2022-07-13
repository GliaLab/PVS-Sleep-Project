clear all

%% Load tseries
ts = get_tseries(true);

%%
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    iris.processing_functions.load_tseries_info(ts(i));
end
