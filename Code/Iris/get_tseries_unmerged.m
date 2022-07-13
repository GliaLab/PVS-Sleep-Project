function ts = get_tseries_unmerged(original)
if nargin < 1
    original = false;
end

begonia.logging.set_level(1);

% Place to save data.
datastore = fullfile(get_project_path(), "Data", "TSeries unmerged data");

if original
    % Load the original data.
    engine = yucca.datanode.OffPathEngine(datastore);
    path = fullfile(get_project_path, "Data", "TSeries unmerged");
    ts = begonia.scantype.find_scans(path);

    if ~isempty(ts)
        [ts.dl_storage_engine] = deal(engine);
    end
else
    engine = yucca.datanode.DataNodeEngine(datastore);
    ts = engine.get_dnodes();
end

end

