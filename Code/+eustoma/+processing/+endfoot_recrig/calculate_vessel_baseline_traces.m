begonia.logging.set_level(1);
rr = eustoma.get_endfoot_recrigs();
ts = eustoma.get_endfoot_tseries();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(rr);
dloc_list.add(ts);

begonia.logging.log(1,'Filtering trials');
rr = rr(rr.has_var('tseries'));
ts = rr.find_dnode('tseries');
rr = rr(ts.has_var('vessel_traces'));
rr = rr(rr.has_var('vessel_baseline_episodes'));
%%
for i = 1:length(rr)
    begonia.logging.log(1,'Calculating vessel baseline traces (%d/%d)',i,length(rr));
    vessel_traces = rr(i).find_dnode('tseries').load_var('vessel_traces');
    vessel_baseline_episodes = rr(i).load_var('vessel_baseline_episodes');
    
    % Make a copy of the table which will be used to save the processed
    % data. 
    N = height(vessel_traces);
    vessel_baseline_traces = vessel_traces;
    vessel_baseline_traces.baseline_endfoot = nan(N,1);
    vessel_baseline_traces.baseline_lumen = nan(N,1);
    vessel_baseline_traces.baseline_peri = nan(N,1);
    
    % Include trial data
    mouse = rr(i).load_var('mouse');
    mouse = repmat({mouse},N,1);
    mouse = categorical(mouse);
    experiment = rr(i).load_var('experiment');
    experiment = repmat({experiment},N,1);
    experiment = categorical(experiment);
    trial = rr(i).load_var('trial');
    trial = repmat({trial},N,1);
    trial = categorical(trial);
    % Create a unique vessel ID
    vessel_id = cell(N,1);
    for ves_idx = 1:height(vessel_traces)
        vessel_id{ves_idx} = sprintf('%s %s',trial(ves_idx),vessel_traces.vessel_type(ves_idx));
    end
    vessel_id = categorical(vessel_id);
    
    % Make a new table and catenate so the trial info are in the first
    % columns.
    vessel_baseline_traces = cat(2,table(mouse,experiment,trial,vessel_id),vessel_baseline_traces);
    
    for ves_idx = 1:height(vessel_traces)
        % Calculate a vector with equal length as the traces with true where the
        % baseline episodes are. Use this to calculate the median value of the
        % vessel traces in all the baseline episodes. 
        baseline = false(1,length(vessel_traces.t{ves_idx}));
        for ep_idx = 1:height(vessel_baseline_episodes)
            t = vessel_traces.t{ves_idx};
            I = t > vessel_baseline_episodes.state_start(ep_idx) & ...
                t < vessel_baseline_episodes.state_end(ep_idx);
            baseline(I) = true;
        end
        
        % Calculate the baseline distances.
        vessel_baseline_traces.baseline_endfoot(ves_idx) = ...
            nanmedian(vessel_traces.distance_endfoot{ves_idx}(baseline));
        
        vessel_baseline_traces.baseline_lumen(ves_idx) = ...
            nanmedian(vessel_traces.distance_lumen{ves_idx}(baseline));
        
        vessel_baseline_traces.baseline_peri(ves_idx) = ...
            nanmedian(vessel_traces.distance_peri{ves_idx}(baseline));
    end
    rr(i).save_var(vessel_baseline_traces);
end
begonia.logging.log(1,'Finished');