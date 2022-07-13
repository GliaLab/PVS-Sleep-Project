function plots_with_NS(tm)
%% Buttons
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('Plot 1', ...
    @(t,m,e) dogbane.trial_processing.plots_with_NS.plot_1(t), false, false);

%% Modifiers
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roi_array');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roi_events');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roi_traces');
mods(end+1) = alyssum_v2.util.TSeriesLoadVar('fov_id');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('ca_signal_gliopil_traces');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'name';
initial_vars{end+1} = 'fov_id';
initial_vars{end+1} = 'roi_array';
initial_vars{end+1} = 'roi_events';
initial_vars{end+1} = 'ca_signal_gliopil_traces';
%% Editor
trials = tm.get_trials();
xylobium.dledit.Editor(trials, actions, initial_vars, mods);
end

