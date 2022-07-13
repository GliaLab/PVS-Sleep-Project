function stabilize_with_normcorre(ts, channel, output_dir)
assert(~isempty(output_dir), "Output directory must be set.")

config = begonia.processing.motion_correction.AlignmentSettings(ts);
config.channel = channel;

% Make the new file path similar to the orignal one, but replace
% unaligned. 
output_path = strrep(ts.path,'TSeries unaligned',output_dir);
output_path = string(output_path);

% Remove file extension.
[directory,filename] = fileparts(output_path);
output_path = fullfile(directory,filename);

if exist(output_path+".h5")
    begonia.logging.log(1,"Skipping " + ts.path)
    % Check if it's ok. The next line will crash if not.
    begonia.scantype.h5.TSeriesH5(char(output_path+".h5"));
    return;
end

% Skip alignement of single frame "TSeries". 
if ts.frame_count == 1
    return;
end

% Stabilize with NoRMCorre.
ts_stabilized = begonia.processing.motion_correction.run_normcorre(ts,output_path,config,'h5');

% Set the uuid to the same as the original so data connected to the
% aligned uuid can be kept if alignment needs to be re-run.
ts_stabilized.dl_unique_id = ts.dl_unique_id;

end

