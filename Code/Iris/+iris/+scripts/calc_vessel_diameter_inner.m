clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var('vessel_linescan'));
ts = ts(ts.has_var('vessel_diameter_threshold'));

%%
for i = 1:length(ts)
    begonia.logging.log(1,'Calculating diameter trial %d/%d',i,length(ts));
    
    % Load neccessary data to calculate the diameter: linescan and
    % threshold.
    vessel_linescan = ts(i).load_var('vessel_linescan');
    vessel_diameter_threshold = ts(i).load_var('vessel_diameter_threshold');
    
    N_vessels = height(vessel_linescan);
    
    vessel_diameter = vessel_linescan;
    
    % Init variables.
    vessel_diameter.linescan = [];
    vessel_diameter.ts_id = repmat("",N_vessels,1);
    vessel_diameter.y = cell(N_vessels,1);
    vessel_diameter.x = cell(N_vessels,1);
    vessel_diameter.vessel_upper = cell(N_vessels,1);
    vessel_diameter.vessel_lower = cell(N_vessels,1);
    
    for j = 1:N_vessels
        % Load linescan image.
        mat = vessel_linescan.linescan{j};
        mat = single(mat);
        
        % Find thresholds for this linescan.
        I = vessel_diameter_threshold.linescan_id == vessel_linescan.linescan_id(j);
        
        dt = 1 / vessel_linescan.fs(j);
        
        vessel_lower = iris.linescan.calc_linescan_diameter(...
            mat, dt, ...
            vessel_diameter_threshold.lower_time(I), ...
            vessel_diameter_threshold.lower_threshold(I), ...
            "inner", "lower");
        
        vessel_upper = iris.linescan.calc_linescan_diameter(...
            mat, dt, ...
            vessel_diameter_threshold.upper_time(I), ...
            vessel_diameter_threshold.upper_threshold(I), ...
            "inner", "upper");
        
        vessel_diameter.vessel_upper{j} = vessel_upper;
        vessel_diameter.vessel_lower{j} = vessel_lower;
        vessel_diameter.y{j} = (vessel_lower - vessel_upper) * vessel_linescan.dx(j);
        vessel_diameter.x{j} = (0:length(vessel_diameter.y{j})-1) * dt;
        vessel_diameter.ts_id(j) = vessel_linescan.linescan_id(j);
    end
    
    vessel_diameter.name(:) = "Vessel diameter";
    vessel_diameter.ylabel(:) = "Diameter (um)";

    ts(i).save_var(vessel_diameter);
end
