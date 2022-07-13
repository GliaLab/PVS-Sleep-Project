begonia.logging.set_level(1);
rr = eustoma.get_sleep_recrig();
ts = eustoma.get_sleep_tseries();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(ts);
dloc_list.add(rr);
%%
begonia.logging.log(1,'Transferring old sleep episodes');
for i = 1:length(rr)
    filename = fullfile(eustoma.get_data_path,rr(i).load_var('path'),'metadata','var.state_episodes.mat');
    if exist(filename,'file')
        data = load(filename);
        rr(i).save_var('state_episodes',data.data);
        
        if rr(i).has_var('tseries')
            rr(i).find_dloc('tseries').save_var('state_episodes',data.data);
        end
    end
end
begonia.logging.log(1,'Finished');