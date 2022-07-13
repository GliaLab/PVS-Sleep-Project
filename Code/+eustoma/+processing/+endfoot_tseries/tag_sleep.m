% Mark which tseries has a labview trial with at least one of each of the
% sleep states.

begonia.logging.set_level(1);
rr = eustoma.get_endfoot_recrigs();
rr = rr(rr.has_var("sleep_episodes"));
rr = rr(rr.has_var("tseries"));

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
    
    sleep_episodes = rr(i).load_var("sleep_episodes");
    
    if any(sleep_episodes.state == "NREM")
        rr(i).find_dnode("tseries").save_var("nrem",true);
    end
    
    if any(sleep_episodes.state == "REM")
        rr(i).find_dnode("tseries").save_var("rem",true);
    end
    
    if any(sleep_episodes.state == "IS")
        rr(i).find_dnode("tseries").save_var("is",true);
    end
end