clear

%% Load tseries
ts = get_tseries_unaligned(true);

%%
for i = 1:length(ts)
    begonia.logging.log(1,"%d / %d",i,length(ts))

    channel = 2;
    iris.processing_functions.stabilize_with_normcorre(ts(i),channel,"TSeries");
    
end
