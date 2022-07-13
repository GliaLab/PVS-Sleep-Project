begonia.logging.set_level(1);

datastore = fullfile(eustoma.get_data_path,'Endfeet Recrig Data');
engine = begonia.data_management.dans_corner.OffPathEngine(datastore);
trials = engine.get_dlocs();

sleep_tbl = begonia.data_management.var2table(trials,'sleep_episodes', ...
    {'mouse','experiment','trial','trial_type'});
sleep_tbl_path = fullfile(eustoma.get_data_path,'Endfeet Tables','sleep_episodes.csv');
begonia.util.save_table(sleep_tbl_path,sleep_tbl);