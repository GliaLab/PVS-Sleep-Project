function tr = get_labview_trials(original)
if nargin < 1
    original = false;
end

begonia.logging.set_level(1);

% Place to save data.
datastore = fullfile(get_project_path(), "Data", "Labview data");

if original
    % Load the original data.
    engine = yucca.datanode.OffPathEngine(datastore);
    path = fullfile(get_project_path, "Data", "Labview");
    tr = yucca.trial_search.find_trials(path);

    [tr.dl_storage_engine] = deal(engine);
else
    engine = yucca.datanode.DataNodeEngine(datastore);
    tr = engine.get_dnodes();
end

end

