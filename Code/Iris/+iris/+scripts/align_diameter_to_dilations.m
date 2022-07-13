clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("vessel_diameter"));
ts = ts(ts.has_var("vessel_dilations"));

%%
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts));
    end
    
    vessel_diameter = ts(i).load_var('vessel_diameter');
    vessel_dilations = ts(i).load_var('vessel_dilations');
    
    % Assign the linescan_id to the vessel_dilations.
    vessel_dilations = innerjoin(vessel_dilations, vessel_diameter(:,["linescan_id","ts_id"]));
    
    % Remove outline of diameter on linescan so it's not passed on to the
    % aligned data.
    vessel_diameter.vessel_upper = [];
    vessel_diameter.vessel_lower = [];
    
    % Align the time series to the dilation time points.
    diameter_aligned_to_dilations = ...
        iris.time_series.align_time_series(vessel_dilations(:,["t0","t0_id","linescan_id"]), vessel_diameter, 15, 15);
    diameter_aligned_to_dilations.name(:) = "Diameter aligned to dilations";
    
    if isempty(diameter_aligned_to_dilations)
        begonia.logging.log(1,"Window outside bounds.");
        continue;
    end
    
    ts(i).save_var(diameter_aligned_to_dilations);
end