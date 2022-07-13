function roa_plots(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('ROA Ignore Tool', ...
    @(d,m,e) xylobium.roa_ignore.RoaIgnoreGUI([d.tseries],'highpass_thresh_roa_mask'), false, true);
actions(end+1) = xylobium.dledit.Action('ROA 3D tool', ...
    @(d,m,e) xylobium.roa_3d_tool.Roa3DTool([d.tseries]), false, false);
actions(end+1) = xylobium.dledit.Action('ROA traces', ...
    @(d,m,e) dogbane.trial_processing.roa_plot.plot_roa_traces(d), false, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('highpass_thresh_roa_mask');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'highpass_thresh_roa_mask';
%%
xylobium.dledit.Editor(trials, actions, initial_vars,mods,false);
end

