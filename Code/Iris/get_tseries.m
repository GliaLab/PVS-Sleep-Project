function ts = get_tseries(original, tseries_folder)
if nargin < 1
    original = false;
end
if nargin < 2
    % The location of the tseries in the "Data" folder.
    tseries_folder = "TSeries";
end

begonia.logging.set_level(1);

% Place to save metadata.
datastore = fullfile(get_project_path(), "Data", tseries_folder + " data");

if original
    % Load the original data.
    engine = yucca.datanode.OffPathEngine(datastore);
    path = fullfile(get_project_path, "Data", tseries_folder);
    ts = begonia.scantype.find_scans(path);

    if ~isempty(ts)
        [ts.dl_storage_engine] = deal(engine);
    end
else
    engine = yucca.datanode.DataNodeEngine(datastore);
    ts = engine.get_dnodes();
end

end

