function aqua(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('aqua', ...
    @(d,m,e) dogbane.trial_processing.aqua.run(d), true, false);

actions(end+1) = xylobium.dledit.Action('aqua parallel', ...
    @(d,m,e) dogbane.trial_processing.aqua.parallel_run(d), false, true);

actions(end+1) = xylobium.dledit.Action('beautify data', ...
    @(d,m,e) dogbane.trial_processing.aqua.beautify_data(d), true, false);

actions(end+1) = xylobium.dledit.Action('aqua gui', ...
    @(d,m,e) dogbane.trial_processing.aqua.aqua_gui(d), false, false);

actions(end+1) = xylobium.dledit.Action('ROA 3D tool', ...
    @(d,m,e) xylobium.roa_3d_tool.Roa3DTool([d.tseries]), false, false);

actions(end+1) = xylobium.dledit.Action('ROA Ignore Tool', ...
    @(d,m,e) xylobium.roa_ignore.RoaIgnoreGUI([d.tseries],'highpass_thresh_roa_mask'), false, true);

actions(end+1) = xylobium.dledit.Action('aqua vs roa freq', ...
    @(d,m,e) dogbane.trial_processing.aqua.roa_vs_aqua_freq(d), false, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('aqua_events_struct');
mods(end+1) = alyssum_v2.util.TSeriesLoadVar('aqua_events');
mods(end+1) = alyssum_v2.util.TSeriesLoadVar('aqua_processing_time');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'aqua_processing_time';
initial_vars{end+1} = 'aqua_events_struct';
initial_vars{end+1} = 'aqua_events';
%%
xylobium.dledit.Editor(trials, actions, initial_vars,mods);
end

