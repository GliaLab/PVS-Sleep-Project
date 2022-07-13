function trials = get_linescans_recrig(original)
if nargin < 1
    original = false;
end

datastore = fullfile(eustoma.get_data_path,'Linescans Recrig Data');
if original
    engine = yucca.datanode.OffPathEngine(datastore);

    path = fullfile(eustoma.get_data_path,'Linescans Recrig');
    trials = yucca.trial_search.find_trials(path);

    [trials.dl_storage_engine] = deal(engine);
else
    engine = yucca.datanode.DataNodeEngine(datastore);
    trials = engine.get_dnodes();
end

end

