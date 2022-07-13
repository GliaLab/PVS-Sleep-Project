
begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('vessel_type'));

for i = 1:length(scans)
    vessel_type = scans(i).load_var('vessel_type');
    vessel_type = strip(vessel_type);
    scans(i).save_var(vessel_type);
end