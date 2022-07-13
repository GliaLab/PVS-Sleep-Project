function merge_frames(ts,merged_frames,output_dir,output_type,input_dir)
% This functions merges frames of a TSeries.
% The output is stored in the 
% "Data/output_dir" folder where output_dir is a string. By default
% output_dir is "TSeries" and the data is thus saved in "Data/TSeries".
if nargin < 2
    merged_frames = 10;
end
if nargin < 3
    output_dir = "TSeries";
end
if nargin < 4
    output_type = "h5";
end
if nargin < 5
    input_dir = "TSeries unmerged";
end

% Create the output path of the resulting merged TSeries.
output_path = strrep(ts.path, "Data/" + input_dir, "Data/" + output_dir);

% Skip single frame "TSeries". 
if ts.frame_count == 1
    return;
end

% Remove file extension.
[directory,filename] = fileparts(output_path);
output_path = fullfile(directory,filename);

% Add correct file extension.
if output_type == "h5"
    output_path = output_path + ".h5";
elseif output_type == "tif"
    output_path = output_path + ".tif";
else
    error("output_type must be tif or h5.");
end

% If file already exists, check if it is readable and skip. If not
% readable the file will be overwritten. 
if output_type == "h5"
    try
        begonia.scantype.h5.TSeriesH5(output_path);
        begonia.logging.log(1,"TSeries with merged frames already detected, skipping.")
        return;
    end
elseif output_type == "tif"
    try
        begonia.scantype.tiff.TSeriesTIFF(output_path);
        begonia.logging.log("TSeries with merged frames already detected, skipping.")
        return;
    end
else
    error("output_type must be tif or h5.");
end

% Merge frames.
if output_type == "h5"
    begonia.scantype.h5.tseries_to_h5(ts,output_path,merged_frames);
elseif output_type == "tif"
    begonia.scantype.tiff.tseries_to_tiff(ts,output_path,merged_frames);
else
    error("output_type must be tif or h5.");
end

% Set the uuid to the same as the original so associated downsteam 
% metadata can be kept.
if output_type == "h5"
    ts_out = begonia.scantype.h5.TSeriesH5(output_path);
elseif output_type == "tif"
    ts_out = begonia.scantype.tiff.TSeriesTIFF(output_path);
else
    error("output_type must be tif or h5.");
end
ts_out.dl_unique_id = ts.dl_unique_id;

end

