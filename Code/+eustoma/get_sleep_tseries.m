function ts = get_sleep_tseries(original)
if nargin < 1
    original = false;
end

datastore = fullfile(eustoma.get_data_path,'Sleep Project TSeries Data');
if original
    engine = yucca.datanode.OffPathEngine(datastore);

    path = fullfile(eustoma.get_data_path,'Sleep Project TSeries','WT');
    ts = begonia.scantype.find_scans(path);

    [ts.dl_storage_engine] = deal(engine);
else
    engine = yucca.datanode.DataNodeEngine(datastore);
    ts = engine.get_dnodes();
end

end