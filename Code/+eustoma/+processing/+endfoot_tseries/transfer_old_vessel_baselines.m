% This script is only ment to be run once to transfer the
% vessel_baselines episodes that were manually marked in the old project.
% If new baseline episodes need to be marked this should be done with
% a gui from the project's code (which will load these old baselines
% episodes and enable editing of them). 

begonia.logging.set_level(1);
datastore = fullfile(eustoma.get_data_path,'Endfeet Recrig Data');
engine = begonia.data_management.dans_corner.OffPathEngine(datastore);
rr = engine.get_dlocs();

%%
old_datastore = fullfile(eustoma.get_data_path(),'Endfeet Experiments');

begonia.logging.log(1,'Transferring old vessel baseline episodes');
for i = 1:length(rr)
    old_uuid = rr(i).load_var('start_time');
    old_uuid.Format = 'uuuu MM dd HH mm ss';
    old_uuid = char(old_uuid);
    
    filename = fullfile(old_datastore,old_uuid,'metadata','var.vessel_baseline_episodes.mat');
    if exist(filename,'file')
        data = load(filename);
        rr(i).save_var('vessel_baseline_episodes',data.data);
    end
end
begonia.logging.log(1,'Finished');