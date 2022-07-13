begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('trial_id'));

%% 
trial_ids = scans.load_var('trial_id');

trial_ids = [trial_ids{:}];

vessel_type = [trial_ids.vessel_type]';
trial_id = [trial_ids.trial_id]';

tbl = table(trial_id,vessel_type);
[~,I] = sort(trial_id);
tbl = tbl(I,:);

tbl_path = fullfile(eustoma.get_plot_path,'Linescan Tables','Vessel Types.csv');
begonia.util.save_table(tbl_path,tbl);
begonia.logging.log(1,'Finished');