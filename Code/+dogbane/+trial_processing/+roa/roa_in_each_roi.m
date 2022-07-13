function roa_in_each_roi(ts)

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

ts.clear_var('roa_in_each_roi');

%% ROA ignore mask.
roa_ignore_mask = ts.load_var('roa_ignore_mask');
edge_ignore_width = 15;
roa_ignore_mask(1:edge_ignore_width,:) = true;
roa_ignore_mask(end-edge_ignore_width:end,:) = true;
roa_ignore_mask(:,1:edge_ignore_width) = true;
roa_ignore_mask(:,end-edge_ignore_width:end) = true;
% Flips it. Result is true where ROAs are allowed. 
roa_ignore_mask = ~roa_ignore_mask; 

%% Load original ROA event matrix
roa_mask = ts.load_var('highpass_roa_mask');

% Remove ROAs with a xy_size lower than a threshold. 
threshold = 0.85; % um^2
roa_mask = begonia.processing.remove_roa_events(roa_mask,dx,threshold);
roa_mask = roa_mask & roa_ignore_mask;

%%
frames = size(roa_mask,3);

dur = seconds(ts.duration);
t = 0:dur*fs; % Time vector in samples.

%% Load ROIs
roi_array = ts.load_var('roi_array');
I = ismember({roi_array.group},{'Gp','AS'});
roi_array = roi_array(I);

if isempty(roi_array)
    return;
end

o = struct;
begonia.util.logging.backwrite();
for i = 1:length(roi_array)
    str = sprintf('roi (%d/%d)',i,length(roi_array));
    begonia.util.logging.backwrite(1,str);
    
    roi = roi_array(i);
    
    % Crop a square around the roi.
    min_x = min(roi.x);
    min_y = min(roi.y);
    max_x = max(roi.x);
    max_y = max(roi.y);

    min_x = max(min_x,1);
    min_y = max(min_y,1);
    max_x = min(max_x,size(roa_mask,2));
    max_y = min(max_y,size(roa_mask,1));
    
    % Crop a 3d matrix of the same size out of the recording. 
    chunk = roa_mask(min_y:max_y, min_x:max_x, :);

    roi_mask = roi.mask(min_y:max_y, min_x:max_x);

    % Areas not in the mask are zero. 
    chunk = chunk & roi_mask;

    roa_density = sum(sum(chunk, 1), 2) / sum(roi_mask(:));
    roa_density = reshape(roa_density,1,[]);
    
    % ROA table
    roa_table = begonia.processing.extract_roa_events(chunk,dx,dt);

    % Frequency traces
    roi_mask_area = sum(roi_mask(:)) * dx * dx;
    roa_frequency = histcounts(roa_table.roa_t_start_idx,t) / dt / roi_mask_area;
    
    
    o(i).roi_id = roi.id;
    o(i).roi_group = roi.group;
    o(i).roa_density = {roa_density};
    o(i).roa_frequency = {roa_frequency};
end

roa_in_each_roi = struct2table(o,'AsArray',true);
roa_in_each_roi.roi_id = categorical(roa_in_each_roi.roi_id);
roa_in_each_roi.roi_group = categorical(roa_in_each_roi.roi_group);
ts.save_var(roa_in_each_roi);

end

