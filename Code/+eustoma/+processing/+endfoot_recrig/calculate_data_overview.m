begonia.logging.set_level(1);
rr = eustoma.get_endfoot_recrigs();
ts = eustoma.get_endfoot_tseries();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(rr);
dloc_list.add(ts);

%%
begonia.logging.log(1,'Loading path');
path = rr.load_var('path')';

begonia.logging.log(1,'Loading connected tseries');
has_connected_tseries = rr.has_var('tseries')';

begonia.logging.log(1,'Loading camera_traces');
has_camera = rr.has_var('camera_traces')';

begonia.logging.log(1,'Loading trial');
XL_sheet_processed = rr.has_var('trial')';

begonia.logging.log(1,'Loading ephys');
ephys_processed = rr.has_var('ephys')';

begonia.logging.log(1,'Loading ephys norm');
ephys_norm_processed = rr.has_var('ephys_norm')';

begonia.logging.log(1,'Loading sleep_episodes');
has_sleep_episodes = rr.has_var('sleep_episodes')';

begonia.logging.log(1,'Loading sleep_transitions');
has_sleep_transitions = rr.has_var('wake_sleep_transitions')';

begonia.logging.log(1,'Loading vessel_traces');
has_vessel_traces = false(length(rr),1);
for i = 1:length(rr)
    if has_connected_tseries(i)
        has_vessel_traces(i) = rr(i).find_dnode('tseries').has_var('vessel_traces');
    end
end

begonia.logging.log(1,'Loading vessel_baseline_episodes');
has_vessel_baseline = rr.has_var('vessel_baseline_episodes')';

tbl = table(path,has_connected_tseries,has_camera,XL_sheet_processed, ...
    ephys_processed,ephys_norm_processed,has_sleep_episodes, ...
    has_sleep_transitions,has_vessel_traces,has_vessel_baseline);
%%
[G,tbl_overview] = findgroups(tbl(:,2:end));
tbl_overview.num_recrig_trials = splitapply(@length,tbl.path,G);

%%
tbl_path = fullfile(eustoma.get_data_path,'Endfeet Tables','data_overview.csv');
begonia.util.save_table(tbl_path,tbl_overview);
begonia.logging.log(1,'Finished');