
begonia.logging.set_level(1);

scans = eustoma.get_linescans(true);
%%
begonia.logging.backwrite();
for i = 1:length(scans)
    begonia.logging.backwrite(1,'load linescan info (%d/%d)',i,length(scans));
    
    try
        linescan_info = scans(i).read_metadata();
    catch e
        begonia.logging.log(1,"Error when reading metadata");
        continue;
    end
    
    if linescan_info.duration < 30
        continue;
    end
    
    path = scans(i).path;
    path = strrep(path,eustoma.get_data_path,'');
    path = strsplit(path,'.');
    path = path{1};
    
    a = strsplit(path,filesep);
    parent_dir = a{3};
    filename = a{4};
    b = strsplit(parent_dir," ");
    recording_str = strrep(filename,"file_","");
    recording = str2double(recording_str);
    
    trial_id = struct;
    trial_id.genotype = string(b{1});
    trial_id.mouse = sprintf("%s %s",b{1},b{2});
    trial_id.date = sprintf("%s %s %s",b{1},b{2},b{3});
    trial_id.vessel_type = string(scans(i).load_var('vessel_type',"Unknown"));
    trial_id.vessel_id = str2double(scans(i).load_var('vessel_id',""));
    if isnan(trial_id.vessel_id)
        trial_id.vessel_id = "";
    else
        trial_id.vessel_id = sprintf("%.3d",trial_id.vessel_id);
    end
    trial_id.trial_id = sprintf("%s %s %s %.2d",b{1},b{2},b{3},recording);
    
    scans(i).save_var(trial_id);
    scans(i).save_var(path);
    scans(i).save_var(linescan_info);
end
begonia.logging.log(1,'Finished')