function roa_in_rois(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('Moving ROI Tool', ...
    @(d,m,e) xylobium.moving_rois.MovingRoiTool([d.tseries]), false, true);

actions(end+1) = xylobium.dledit.Action('ROA in endfeet', ...
    @(d,m,e) dogbane.trial_processing.roa_in_rois.roa_in_endfeet(d), true, false);

actions(end+1) = xylobium.dledit.Action('ROA in endfeet transitions', ...
    @(d,m,e) dogbane.trial_processing.roa_in_rois.roa_in_endfeet_transitions(d), true, false);

actions(end+1) = xylobium.dledit.Action('ROA in endfeet transitions_strict', ...
    @(d,m,e) dogbane.trial_processing.roa_in_rois.roa_in_endfeet_transitions_strict(d), true, false);

actions(end+1) = xylobium.dledit.Action('Plot ROA in endfeet transitions', ...
    @(d,m,e) dogbane.trial_processing.roa_in_rois.roa_in_endfeet_transitions_plot(d), false, true);

actions(end+1) = xylobium.dledit.Action('ROA in endfeet states', ...
    @(d,m,e) dogbane.trial_processing.roa_in_rois.roa_in_endfeet_states(d), true, false);

actions(end+1) = xylobium.dledit.Action('roa_in_rois', ...
    @(d,m,e) alyssum_v2.processing_tseries.roa.roa_in_rois(d.tseries), true, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_in_endfeet');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_in_endfeet_states');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_in_endfeet_transitions');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_in_endfeet_transitions_strict');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'roa_in_endfeet';
initial_vars{end+1} = 'roa_in_endfeet_states';
initial_vars{end+1} = 'roa_in_endfeet_transitions';
initial_vars{end+1} = 'roa_in_endfeet_transitions_strict';
%%
xylobium.dledit.Editor(trials, actions, initial_vars,mods);
end

