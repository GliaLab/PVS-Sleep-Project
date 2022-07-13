function roa_in_rois(ts)

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

%% ROA ignore mask.
roa_ignore_mask = ts.load_var('roa_ignore_mask');
edge_ignore_width = 15;
roa_ignore_mask(1:edge_ignore_width,:) = true;
roa_ignore_mask(end-edge_ignore_width:end,:) = true;
roa_ignore_mask(:,1:edge_ignore_width) = true;
roa_ignore_mask(:,end-edge_ignore_width:end) = true;
% Flips it. Result is true where ROAs are allowed. 
roa_ignore_mask = ~roa_ignore_mask;

%% Create new ROA ignore masks based on ROIs
roi_array = ts.load_var('roi_array');

roa_ignore_mask_AS = begonia.processing.merged_roi_mask(roi_array,'AS',size(roa_ignore_mask));
roa_ignore_mask_Gp = begonia.processing.merged_roi_mask(roi_array,'Gp',size(roa_ignore_mask));
roa_ignore_mask_not_AS = ~begonia.processing.merged_roi_mask(roi_array,'AS',size(roa_ignore_mask));

roa_ignore_mask_AS = roa_ignore_mask_AS & roa_ignore_mask;
roa_ignore_mask_Gp = roa_ignore_mask_Gp & roa_ignore_mask;
roa_ignore_mask_not_AS = roa_ignore_mask_not_AS & roa_ignore_mask;

roa_ignore_mask_AS_area = sum(roa_ignore_mask_AS(:)) * dx * dx;
roa_ignore_mask_Gp_area = sum(roa_ignore_mask_Gp(:)) * dx * dx;
roa_ignore_mask_not_AS_area = sum(roa_ignore_mask_not_AS(:)) * dx * dx;

%% Load original ROA event matrix
roa_mask = ts.load_var('highpass_roa_mask');

% Remove ROAs with a xy_size lower than a threshold. 
threshold = 0.85; % um^2
roa_mask = begonia.processing.remove_roa_events(roa_mask,dx,threshold);

%% ROA masks based on ROIs
roa_mask_AS     = roa_mask & roa_ignore_mask_AS;
roa_mask_Gp     = roa_mask & roa_ignore_mask_Gp;
roa_mask_not_AS = roa_mask & roa_ignore_mask_not_AS;

%% Calculate traces
% Density traces
roa_density_trace_AS = sum(sum(roa_mask_AS,1),2)/sum(roa_ignore_mask_AS(:));
roa_density_trace_AS = squeeze(roa_density_trace_AS);

roa_density_trace_Gp = sum(sum(roa_mask_Gp,1),2)/sum(roa_ignore_mask_Gp(:));
roa_density_trace_Gp = squeeze(roa_density_trace_Gp);

roa_density_trace_not_AS = sum(sum(roa_mask_not_AS,1),2)/sum(roa_ignore_mask_not_AS(:));
roa_density_trace_not_AS = squeeze(roa_density_trace_not_AS);

% ROA table
roa_table_AS = begonia.processing.extract_roa_events(roa_mask_AS,dx,dt);
roa_table_Gp = begonia.processing.extract_roa_events(roa_mask_Gp,dx,dt);
roa_table_not_AS = begonia.processing.extract_roa_events(roa_mask_not_AS,dx,dt);

% Frequency traces
dur = seconds(ts.duration);
t = 0:dur*fs;
roa_frequency_trace_AS = histcounts(roa_table_AS.roa_t_start_idx,t) / dt / roa_ignore_mask_AS_area;
roa_frequency_trace_Gp = histcounts(roa_table_Gp.roa_t_start_idx,t) / dt / roa_ignore_mask_Gp_area;
roa_frequency_trace_not_AS = histcounts(roa_table_not_AS.roa_t_start_idx,t) / dt / roa_ignore_mask_not_AS_area;

% Frequency per roi traces
N_AS = sum(strcmp({roi_array.group},'AS'));
N_Gp = sum(strcmp({roi_array.group},'Gp'));

roa_roi_frequency_trace_AS = histcounts(roa_table_AS.roa_t_start_idx,t) / dt / N_AS;
roa_roi_frequency_trace_Gp = histcounts(roa_table_Gp.roa_t_start_idx,t) / dt / N_Gp;

%% Save
if N_AS ~= 0
    ts.save_var(roa_ignore_mask_AS);
    ts.save_var(roa_ignore_mask_AS_area);
    ts.save_var(roa_table_AS);
    ts.save_var(roa_density_trace_AS);
    ts.save_var(roa_frequency_trace_AS);
    ts.save_var(roa_roi_frequency_trace_AS);
    
    ts.save_var(roa_ignore_mask_not_AS);
    ts.save_var(roa_ignore_mask_not_AS_area);
    ts.save_var(roa_table_not_AS);
    ts.save_var(roa_density_trace_not_AS);
    ts.save_var(roa_frequency_trace_not_AS);
end

if N_Gp ~= 0
    ts.save_var(roa_ignore_mask_Gp);
    ts.save_var(roa_ignore_mask_Gp_area);
    ts.save_var(roa_table_Gp);
    ts.save_var(roa_density_trace_Gp);
    ts.save_var(roa_frequency_trace_Gp);
    ts.save_var(roa_roi_frequency_trace_Gp);
end
end

