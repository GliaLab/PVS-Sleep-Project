function roa_clusters(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('ROA clusters', ...
    @(d,m,e) dogbane.trial_processing.roa_cluster.count_clusters(d), true, false);
actions(end+1) = xylobium.dledit.Action('Plot n(s,p)', ...
    @(d,m,e) dogbane.trial_processing.roa_cluster.plot_clusters(d), false, false);
actions(end+1) = xylobium.dledit.Action('Plot traces', ...
    @(d,m,e) dogbane.trial_processing.roa_plot.plot_roa_traces(d), false, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('highpass_thresh_roa_mask');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_cluster_number_density');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'highpass_thresh_roa_mask';
initial_vars{end+1} = 'roa_cluster_number_density';
%%
xylobium.dledit.Editor(trials, actions, initial_vars,mods);
end

