function neu_ast_cor(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('roa_in_rois', ...
    @(d,m,e) alyssum_v2.processing_tseries.roa.roa_in_rois(d.tseries), ...
    true, false);
actions(end+1) = xylobium.dledit.Action('ca_signal_Gp_neu', ...
    @(t,m,e) alyssum_v2.processing_tseries.roi.ca_signal_Gp_neu([t.tseries]), ...
    true, false);
actions(end+1) = xylobium.dledit.Action('ca_signal_gliopil_traces', ...
    @(t,m,e) alyssum_v2.processing_tseries.roi.ca_signal_gliopil_traces([t.tseries]), ...
    true, false);
actions(end+1) = xylobium.dledit.Action('correlate_gliopil_traces', ...
    @(t,m,e) dogbane.trial_processing.neu_ast_correlation.correlate_gliopil_traces(t), ...
    true, false);
actions(end+1) = xylobium.dledit.Action('Plot ROA vs. Neu. Gp traces', ...
    @(t,m,e) dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp(t), ...
    false, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('highpass_roa_mask');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('ca_signal_gliopil_traces');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('correlate_gliopil_traces');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('ca_signal_Gp_neu');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_frequency_trace_Gp');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'ca_signal_Gp_neu';
initial_vars{end+1} = 'ca_signal_gliopil_traces';
initial_vars{end+1} = 'correlate_gliopil_traces';
initial_vars{end+1} = 'roa_frequency_trace_Gp';
%%
e = xylobium.dledit.Editor(trials, actions,initial_vars,mods);


end