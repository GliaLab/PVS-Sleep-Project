clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("trial_id"));

%%
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    trial_id = ts(i).load_var("trial_id");
    
    trial_id_parts = strrep(trial_id,"_"," ");
    trial_id_parts = split(trial_id_parts);
    
    trial_group = table;
    trial_group.genotype = trial_id_parts(11);
    trial_group.mouse = trial_id_parts(12) + " " + trial_id_parts(13);
    trial_group.puff_type = trial_id_parts(15);
    trial_group.trial_id = string(trial_id);
    
    ts(i).save_var(trial_group);
end
