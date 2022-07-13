function scans = get_linescans(original)
if nargin < 1
    original = false;
end

datastore = fullfile(eustoma.get_data_path,'Linescans Data');
engine = yucca.datanode.DataNodeEngine(datastore);

if original
    scan_path = fullfile(eustoma.get_data_path,'Linescans');
    scans = eustoma.linescan.find_linescans(scan_path,engine);
else
    scans = engine.get_dnodes();
end
end

