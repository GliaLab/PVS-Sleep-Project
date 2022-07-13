function roa_in_endfeet(trial)

ts = trial.tseries;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

ts.clear_var('roa_in_endfeet');

%% Create new ROA ignore masks based on ROIs
roi_array = ts.load_var('roi_array',[]);
roi_array = xylobium.moving_rois.ROI(roi_array);
if isempty(roi_array)
    begonia.util.logging.vlog(1,'Missing roi_array');
    return;
end

I = ismember({roi_array.group},{'Ar','Ve','Ca'});
if ~any(I)
    begonia.util.logging.vlog(1,'No endfeet');
    return;
end
roi_array = roi_array(I);

%%
roa_mask = ts.load_var('highpass_thresh_roa_mask',[]);
if isempty(roa_mask)
    begonia.util.logging.vlog(1,'Missing roa_mask');
    return;
end

%%
o = struct;

begonia.util.logging.backwrite();
for i = 1:length(roi_array)
    begonia.util.logging.backwrite(1,'roi %d/%d',i,length(roi_array));
    roi = roi_array(i);
    
    roi.frames = size(roa_mask,3);
    
    [roi_mask,bb] = roi.get_3d_mask();
    
    mask = roa_mask(bb(1):bb(2),bb(3):bb(4),:);
    roi_mask = roi_mask(bb(1):bb(2),bb(3):bb(4),:);
    
    mask = mask & roi_mask;
    
    area = sum(roi.mask(:));
    
    % Density trace
    roa_density_trace = sum(sum(mask,1),2)/area;
    roa_density_trace = reshape(roa_density_trace,1,[]);

    % ROA table
    roa_table = begonia.processing.extract_roa_events(mask,dx,dt);

    % Frequency traces
    t = 1:size(mask,3)+1;
    roi_area = area * dx * dx;
    roa_frequency_trace = histcounts(roa_table.roa_t_start_idx,t) / dt / roi_area;
    
    o(i).roi_id = roi.id;
    o(i).roi_group = roi.group;
    o(i).roa_density_trace = roa_density_trace;
    o(i).roa_frequency_trace = roa_frequency_trace;
end

roa_in_endfeet = struct2table(o,'AsArray',true);
roa_in_endfeet.roi_id       = categorical(roa_in_endfeet.roi_id);
roa_in_endfeet.roi_group    = categorical(roa_in_endfeet.roi_group);

ts.save_var(roa_in_endfeet);

end

