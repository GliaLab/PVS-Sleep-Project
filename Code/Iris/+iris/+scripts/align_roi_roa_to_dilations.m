clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("roi_roa_time_series"));
ts = ts(ts.has_var("vessel_diameter"));
ts = ts(ts.has_var("vessel_dilations"));

%%
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts));
    end
    
    roi_roa_time_series = ts(i).load_var('roi_roa_time_series');
    vessel_diameter = ts(i).load_var('vessel_diameter');
    vessel_dilations = ts(i).load_var('vessel_dilations');
    
    % Assign the linescan_id to the vessel_dilations.
    vessel_dilations = innerjoin(vessel_dilations, vessel_diameter(:,["linescan_id","ts_id"]));
    
    % Assign a linescan_id to each ROI based on distance (30 um).
    distance_threshold_pix = 30 / vessel_diameter.dx(1); 
    roi_roa_time_series = iris.position.join_by_center_distance( ...
        roi_roa_time_series, ...
        vessel_diameter(:,["linescan_id","center"]), ...
        distance_threshold_pix);
    
    % Align the time series to the dilation time points.
    roi_roa_aligned_to_dilations = ...
        iris.time_series.align_time_series(vessel_dilations(:,["t0","t0_id","linescan_id"]), roi_roa_time_series, 15, 15);
    roi_roa_aligned_to_dilations.name(:) = "ROA density in ROI aligned to dilations";
    
    if isempty(roi_roa_aligned_to_dilations)
        begonia.logging.log(1,"Window outside bounds.");
        continue;
    end
    
    ts(i).save_var(roi_roa_aligned_to_dilations);
end