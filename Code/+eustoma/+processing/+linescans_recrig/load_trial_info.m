
begonia.logging.set_level(1);

trials = eustoma.get_linescans_recrig(true);
%%
begonia.logging.backwrite();
for i = 1:length(trials)
    begonia.logging.backwrite(1,'Trial %d/%d',i,length(trials));
    start_time = trials(i).start_time;
    duration = seconds(trials(i).duration);
    
    path = trials(i).path;
    path = strrep(path,eustoma.get_data_path,'');
    
    trials(i).save_var(start_time);
    trials(i).save_var(duration);
    trials(i).save_var(path);
end
begonia.logging.log(1,'Finished')