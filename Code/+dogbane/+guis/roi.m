function roi(tm)
%% Buttons
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('ROI Manager', ...
    @(t,m,e) roimanager_lite([t.tseries]), false, true);

actions(end+1) = xylobium.dledit.Action('Find Events', ...
    @(t,m,e) dogbane.trial_processing.roi.roi_events([t.tseries]), true, false);

actions(end+1) = xylobium.dledit.Action('Extract Traces', ...
    @(t,m,e) dogbane.trial_processing.roi.roi_traces(t), true, false);

actions(end+1) = xylobium.dledit.Action('Plot Traces', ...
    @(t,m,e) dogbane.trial_processing.roi.plot_roi_traces(t), false, false);

actions(end+1) = xylobium.dledit.Action('ROI Avg. Response', ...
    @(t,m,e) dogbane.trial_processing.roi.roi_response_per_episode(t), true, false);

actions(end+1) = xylobium.dledit.Action('ROI Transitions', ...
    @(t,m,e) dogbane.trial_processing.roi.roi_transitions(t), true, false);

%% Modifiers
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roi_array');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roi_events');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roi_traces');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roi_response_per_episode');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'name';
initial_vars{end+1} = 'roi_array';
initial_vars{end+1} = 'roi_events';
initial_vars{end+1} = 'roi_traces';
initial_vars{end+1} = 'roi_response_per_episode';
%% Editor
trials = tm.get_trials();
xylobium.dledit.Editor(trials, actions, initial_vars, mods);
end

