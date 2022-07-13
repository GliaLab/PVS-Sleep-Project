begonia.logging.set_level(1);

datastore = fullfile(eustoma.get_data_path,'Linescans Data');
engine = yucca.datanode.DataNodeEngine(datastore);

scans = eustoma.linescan.find_linescans('/Volumes/Storage2/Neoendfeet (move into pices)/Data/Linescans/WT 10 20210422',engine);

%%

i = 6;
disp(scans(i).path)
linescan_info = scans(i).read_metadata

merged_samples = round(1 / linescan_info.dx / 20)

%%
vessels_red_raw = scans(i).load_var("vessels_red_raw")

vessels_red_raw.linescan = vessels_red_raw.vessel;
vessels_red_raw.dx = vessels_red_raw.vessel_dx;
vessels_red_raw.fs = vessels_red_raw.vessel_fs;

iris.linescan.plot_vessel_linescan(vessels_red_raw)