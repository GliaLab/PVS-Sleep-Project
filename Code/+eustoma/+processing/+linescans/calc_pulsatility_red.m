begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red_baseline'));

%%
for i = 1:length(scans)
    pulsatility_red = scans(i).load_var('diameter_red_baseline');
    N_vessels = height(pulsatility_red);
    
    pulsatility_red.pulsatility = cell(N_vessels,1);
    pulsatility_red.t = cell(N_vessels,1);
        
    for j = 1:height(pulsatility_red)
        fs = pulsatility_red.vessel_fs(j);
        pulsatility = pulsatility_red.diameter{j};
        
        % Smooth with a 3 sec window.
        vec = ones(1,round(fs*3)) / round(fs*3);
        pulsatility = pulsatility - conv(pulsatility,vec,'same');
        t = (0:length(pulsatility)-1) / fs;
        
        pulsatility_red.pulsatility{j} = pulsatility;
        pulsatility_red.t{j} = t;
    end
    scans(i).save_var(pulsatility_red);
end