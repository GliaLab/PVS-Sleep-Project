% Merge frames from "Data/TSeries unmerged" and export to "Data/TSeries tiff"
clear

%% Load tseries
ts = get_tseries_unmerged(true);

%%
merged_frames = 10;
input_dir = "TSeries unmerged";
output_dir = "TSeries tiff";
output_type = "tif";

for i = 1:length(ts)
    begonia.logging.log(1,"%d / %d",i,length(ts))
    
    iris.processing_functions.merge_frames(ts(i),merged_frames,output_dir,output_type,input_dir);
end

