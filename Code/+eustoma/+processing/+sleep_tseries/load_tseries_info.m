begonia.logging.set_level(1);

ts = eustoma.get_sleep_tseries(true);

%%
for i = 1:length(ts)
    begonia.logging.log(1,'load_tseries_info %d/%d',i,length(ts));
    start_time = ts(i).start_time;
    duration = seconds(ts(i).duration);
    
    path = ts(i).path;
    path = strrep(path,eustoma.get_data_path(),'');
    
    ts(i).save_var(start_time);
    ts(i).save_var(duration);
    ts(i).save_var(path);
end
begonia.logging.log(1,'Finished')