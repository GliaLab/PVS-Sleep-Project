clear all

%% Load tseries
ts = get_tseries(true);
ts = ts(ts.has_var("trial_id"));
ts = ts(ts.has_var("roi_table"));

%%

tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    % Load ROI outlines.
    roi_table = ts(i).load_var('roi_table');
    
    trial_id = ts(i).load_var("trial_id");
    trial_id = string(trial_id);
    
    roi_time_series = table;
    roi_time_series.trial_id = repmat(trial_id, height(roi_table), 1);
    roi_time_series.roi_id = roi_table.roi_id;
    roi_time_series.roi_group = roi_table.type;
    roi_time_series.channel = roi_table.channel;
    roi_time_series.roi_indices = cell(height(roi_table),1);
    roi_time_series.roi_short_name = roi_table.short_name;
    roi_time_series.center = zeros(height(roi_table),2);
    roi_time_series.x = cell(height(roi_table),1);
    roi_time_series.y = cell(height(roi_table),1);
    roi_time_series.img_dim = repmat(ts(i).img_dim,height(roi_table),1);
    roi_time_series.fs(:) = 1 / ts(i).dt;
    roi_time_series.ylabel(:) = "Fluorescence (a.u.)";
    roi_time_series.name(:) = "ROI raw fluorescence";
    roi_time_series.roi_indices = cellfun(@(x){find(x)'}, roi_table.mask);
    
    % Extract the roi time series one channel at the time.
    for ch = 1:ts(i).channels
        % Load recording data.
        mat = ts(i).get_mat(ch);
        
        % Load all data into memory for speed, ts.get_mat usually gives a lazy
        % matrix. 
        mat = mat(:,:,:);
        
        % Find the ROIs belonging to this channel.
        rows = find(roi_table.channel == ch)';
        for row = rows
            % Get the roi mask. 
            mask = roi_table.mask{row};
            
            % Calculate the center of the ROI.
            [cy,cx] = find(mask);
            roi_time_series.center(row,:) = [mean(cx), mean(cy)];
            
            % Determine edges of mask.
            fx = find(sum(mask, 1) > 0, 1, 'first');
            fy = find(sum(mask, 2) > 0, 1, 'first');
            tx = find(sum(mask, 1) > 0, 1, 'last');
            ty = find(sum(mask, 2) > 0, 1, 'last');

            % Calculate the number of pixels in the ROI.
            area = sum(mask(:));
            
            % Cast mask to the same type as the input matrix. Because the matrix is
            % often lazy we first read the first value.
            mask = cast(mask,'like',mat(1,1,1));

            % For speed and memory, crop the bounding box around the ROI.
            mat_roi = mat(fy:ty, fx:tx,:) .* mask(fy:ty, fx:tx);

            % Calculate average fluo in each frame: average = sum / area (observed pixels):
            y = sum(sum(mat_roi,2), 1) ./ area;
            y = reshape(y,1,[]);
            
            roi_time_series.y{row} = y;
            
            % Calculate the time vector.
            roi_time_series.x{row} = (0:length(y)-1) * ts(i).dt;
        end
    end
    
    ts(i).save_var(roi_time_series);
end
