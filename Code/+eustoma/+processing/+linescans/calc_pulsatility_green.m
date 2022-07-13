begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_green_baseline'));

%%
for i = 1:length(scans)
    pulsatility_green = scans(i).load_var('diameter_green_baseline');
    N_vessels = height(pulsatility_green);
    
    pulsatility_green.pulsatility = cell(N_vessels,1);
    pulsatility_green.t = cell(N_vessels,1);
        
    for j = 1:height(pulsatility_green)
        fs = pulsatility_green.vessel_fs(j);
        pulsatility = pulsatility_green.diameter{j};
        
        % Smooth with a 3 sec window.
        vec = ones(1,round(fs*3)) / round(fs*3);
        pulsatility = pulsatility - conv(pulsatility,vec,'same');
        t = (0:length(pulsatility)-1) / fs;
        
        pulsatility_green.pulsatility{j} = pulsatility;
        pulsatility_green.t{j} = t;
    end
    scans(i).save_var(pulsatility_green);
end