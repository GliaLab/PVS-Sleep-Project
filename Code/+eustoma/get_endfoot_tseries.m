function ts = get_endfoot_tseries(original)
if nargin < 1
    original = false;
end

datastore = fullfile(eustoma.get_data_path,'Endfeet TSeries Data');
if original
    engine = yucca.datanode.OffPathEngine(datastore);

    path = fullfile(eustoma.get_data_path,'Endfeet TSeries');
    ts = begonia.scantype.find_scans(path);

    [ts.dl_storage_engine] = deal(engine);
else
    engine = yucca.datanode.DataNodeEngine(datastore);
    ts = engine.get_dnodes();
end

end