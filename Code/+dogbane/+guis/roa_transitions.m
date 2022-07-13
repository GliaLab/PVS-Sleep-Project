function roa_transitions(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Calculate ROA transitions', ...
    @(d,m,e) dogbane.trial_processing.roa.roa_transitions(d), ...
    true, false);

actions(end+1) = xylobium.dledit.Action('Microarousal transitions', ...
    @(d,m,e) dogbane.trial_processing.roa.microarousal_transitions(d), ...
    true, false);

actions(end+1) = xylobium.dledit.Action('Stats traces', ...
    @(d,m,e) dogbane.trial_processing.roa.roa_stats_traces(d), ...
    true, false);

actions(end+1) = xylobium.dledit.Action('Stats transitions', ...
    @(d,m,e) dogbane.trial_processing.roa.roa_stats_transitions(d), ...
    true, false);

actions(end+1) = xylobium.dledit.Action('Awakening stats transitions', ...
    @(d,m,e) dogbane.trial_processing.roa.roa_stats_transitions_awakenings(d), ...
    true, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('highpass_thresh_roa_mask');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_transitions');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('microarousal_transitions');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_duration_trace');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_stats_transitions');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_stats_transitions_awakenings');
%%

initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'highpass_thresh_roa_mask';
initial_vars{end+1} = 'roa_transitions';
initial_vars{end+1} = 'microarousal_transitions';
initial_vars{end+1} = 'roa_duration_trace';
initial_vars{end+1} = 'roa_stats_transitions';
initial_vars{end+1} = 'roa_stats_transitions_awakenings';
%%
xylobium.dledit.Editor(trials, actions, initial_vars,mods);
end

