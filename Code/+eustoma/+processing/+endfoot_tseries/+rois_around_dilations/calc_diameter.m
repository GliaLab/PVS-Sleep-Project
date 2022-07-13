clear all
%%
ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('vessel_table'));
ts = ts(ts.has_var('vessel_threshold'));
%%
for i = 1:length(ts)
    begonia.logging.log(1,'Calculating diameter trial %d/%d',i,length(ts));
    
    vessel_table = ts(i).load_var('vessel_table');
    vessel_threshold = ts(i).load_var('vessel_threshold');
    
    N_vessels = height(vessel_table);
    
    diameter = vessel_table;
    diameter.vessel_fs_raw = diameter.vessel_fs;
    diameter.vessel = [];
    diameter.diameter = cell(N_vessels,1);
    diameter.diameter_raw = cell(N_vessels,1);
    diameter.vessel_upper = cell(N_vessels,1);
    diameter.vessel_lower = cell(N_vessels,1);
    
    for j = 1:N_vessels
        
        mat = vessel_table.vessel{j};
        mat = single(mat);
        
        I = vessel_threshold.vessel_index == j;
        
        dt = 1 / vessel_table.vessel_fs(j);
        
        vessel_lower = yucca.processing.detect_linescan_diameter.threshold_linescan(...
            mat, dt, ...
            vessel_threshold.lower_time(I), ...
            vessel_threshold.lower_threshold(I), ...
            "outer", "lower");
        
        vessel_upper = yucca.processing.detect_linescan_diameter.threshold_linescan(...
            mat, dt, ...
            vessel_threshold.upper_time(I), ...
            vessel_threshold.upper_threshold(I), ...
            "outer", "upper");
        
        diameter.vessel_upper{j} = vessel_upper;
        diameter.vessel_lower{j} = vessel_lower;
        diameter.diameter_raw{j} = (vessel_lower - vessel_upper) * vessel_table.vessel_dx(j);
        
        % Resample to 6 Hz. 
        t = (0:length(vessel_lower)-1) * dt;
        diameter.diameter{j} = resample(diameter.diameter_raw{j},t,6);
        diameter.vessel_fs(j) = 6;
    end

    ts(i).save_var(diameter);
end
begonia.logging.log(1,'Finished');