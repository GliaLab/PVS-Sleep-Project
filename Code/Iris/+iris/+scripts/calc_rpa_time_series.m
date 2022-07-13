clear all

%% Load tseries
ts = get_tseries(true);
ts = ts(ts.has_var("trial_id"));
ts = ts(ts.has_var("roi_table"));
ts = ts(ts.has_var("roa_param"));
ts = ts(ts.has_var("roa_mask"));

%%

tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    roa_param = ts(i).load_var('roa_param');
    roi_table = ts(i).load_var('roi_table');
    
    % Only select ROIs with the correct channel.
    roi_table = roi_table(roi_table.channel == roa_param.channel,:);
    if isempty(roi_table)
        continue;
    end
    
    trial_id = ts(i).load_var("trial_id");
    trial_id = string(trial_id);
    
    rpa_time_series = table;
    rpa_time_series.trial_id = repmat(trial_id, height(roi_table), 1);
    rpa_time_series.roi_id = roi_table.roi_id;
    rpa_time_series.roi_group = roi_table.type;
    rpa_time_series.channel = roi_table.channel;
    rpa_time_series.roi_indices = cell(height(roi_table),1);
    rpa_time_series.roi_short_name = roi_table.short_name;
    rpa_time_series.center = zeros(height(roi_table),2);
    rpa_time_series.x = cell(height(roi_table),1);
    rpa_time_series.y = cell(height(roi_table),1);
    rpa_time_series.img_dim = repmat(ts(i).img_dim,height(roi_table),1);
    rpa_time_series.fs(:) = 1 / ts(i).dt;
    rpa_time_series.ylabel(:) = "RPA (fraction of ROI with activity)";
    rpa_time_series.name(:) = "RPA (ROI Pixel Activity)";
    rpa_time_series.roi_indices = cellfun(@(x){find(x)'}, roi_table.mask);
    
    % Extract the rpa time series.
    roa_mask = ts(i).load_var("roa_mask");

    for row = 1:height(roi_table)
        % Get the roi mask. 
        mask = roi_table.mask{row};

        % Calculate the center of the ROI.
        [cy,cx] = find(mask);
        rpa_time_series.center(row,:) = [mean(cx), mean(cy)];

        % Determine edges of mask.
        fx = find(sum(mask, 1) > 0, 1, 'first');
        fy = find(sum(mask, 2) > 0, 1, 'first');
        tx = find(sum(mask, 1) > 0, 1, 'last');
        ty = find(sum(mask, 2) > 0, 1, 'last');

        % Calculate the number of pixels in the ROI.
        area = sum(mask(:));

        % For speed and memory, crop the bounding box around the ROI.
        mat_roi = roa_mask(fy:ty, fx:tx,:) & mask(fy:ty, fx:tx);

        % Calculate average number of active pixels in each frame.
        y = sum(sum(mat_roi,2), 1) ./ area;
        y = reshape(y,1,[]);

        rpa_time_series.y{row} = y;

        % Calculate the time vector.
        rpa_time_series.x{row} = (0:length(y)-1) * ts(i).dt * roa_param.roa_t_smooth;
    end
    
    ts(i).save_var(rpa_time_series);
end
