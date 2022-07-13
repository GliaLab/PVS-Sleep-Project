begonia.logging.set_level(1);
rr = eustoma.get_endfoot_recrigs();
rr = rr(rr.has_var('vessel_baseline_traces'));
rr = rr(rr.has_var('episodes'));
%%
for i = 1:length(rr)
    traces = rr(i).load_var('vessel_baseline_traces');
    episodes = rr(i).load_var('episodes');
    
    tbls = cell(height(traces),1);
    for ves_idx = 1:height(traces)
        tbl = episodes;
        N_ep = height(episodes);
        tbl.vessel_id = repmat(traces.vessel_id(ves_idx),N_ep,1);
        tbl.vessel_type = repmat(traces.vessel_type(ves_idx),N_ep,1);
        tbl.baseline_endfoot = repmat(traces.baseline_endfoot(ves_idx),N_ep,1);
        tbl.baseline_lumen = repmat(traces.baseline_lumen(ves_idx),N_ep,1);
        tbl.baseline_peri = repmat(traces.baseline_peri(ves_idx),N_ep,1);
        tbl.dist_endfoot = nan(N_ep,1);
        tbl.dist_lumen = nan(N_ep,1);
        tbl.dist_peri = nan(N_ep,1);
        
        t = traces.t{ves_idx};
        for ep_idx = 1:N_ep
            I = t >= episodes.state_start(ep_idx) & t < episodes.state_end(ep_idx);
            
            tbl.dist_endfoot(ep_idx) = nanmedian(traces.distance_endfoot{ves_idx}(I));
            tbl.dist_lumen(ep_idx) = nanmedian(traces.distance_lumen{ves_idx}(I));
            tbl.dist_peri(ep_idx) = nanmedian(traces.distance_peri{ves_idx}(I));
        end
            
        tbl.diff_endfoot = tbl.dist_endfoot - tbl.baseline_endfoot;
        tbl.diff_lumen = tbl.dist_lumen - tbl.baseline_lumen;
        tbl.diff_peri = tbl.dist_peri - tbl.baseline_peri;
        tbl.area_peri = pi * tbl.dist_endfoot.^2 - pi * tbl.dist_lumen.^2;
        tbl.area_peri_baseline = pi * tbl.baseline_endfoot.^2 - pi * tbl.baseline_lumen.^2;
        tbl.area_diff_peri = tbl.area_peri - tbl.area_peri_baseline;
        
        tbls{ves_idx} = tbl;
    end
    vesdist_per_ep = cat(1,tbls{:});
    rr(i).save_var(vesdist_per_ep);
end