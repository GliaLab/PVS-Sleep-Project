% Mark which tseries has a labview trial with at least one of each of the
% sleep states.

begonia.logging.set_level(1);
rr = eustoma.get_endfoot_recrigs();
rr = rr(rr.has_var("tseries"));
rr = rr(rr.has_var("trial"));

ts = eustoma.get_endfoot_tseries();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(rr);
dloc_list.add(ts);

%%
tic
for i = 1:length(rr)
    if toc > 1 || i == 1 || i == length(rr)
        begonia.logging.log(1,"Trial %d/%d",i,length(rr));
        tic
    end
    
    trial = rr(i).load_var("trial");
    rr(i).find_dnode("tseries").save_var(trial);
    
    mouse = rr(i).load_var("mouse");
    rr(i).find_dnode("tseries").save_var(mouse);
    
    experiment = rr(i).load_var("experiment");
    rr(i).find_dnode("tseries").save_var(experiment);
    
    trial_type = rr(i).load_var("trial_type");
    rr(i).find_dnode("tseries").save_var(trial_type);
end