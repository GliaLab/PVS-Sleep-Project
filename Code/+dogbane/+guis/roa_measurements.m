function roa_measurements(tm)
%%
trials = tm.get_trials();
%% Buttons
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('roa_heatmap_per_episode', ...
    @(d,m,e) alyssum_v2.processing_trial.roa.roa_heatmap_per_episode(d), ...
    true, ...
    false);
actions(end+1) = xylobium.dledit.Action('roa_distributions', ...
    @(t,m,e) dogbane.trial_processing.roa.roa_distributions(t), ...
    true, ...
    false);
% actions(end+1) = xylobium.dledit.Action('roa_frequency_zscore', ...
%     @(t,m,e) dogbane.trial_processing.roa.roa_frequency_zscore(t), ...
%     true, ...
%     false);
% actions(end+1) = xylobium.dledit.Action('roa_distribution_movie', ...
%     @(t,m,e) dogbane.trial_processing.roa.plot_roa_distribution_movie(t), ...
%     false, ...
%     false);
actions(end+1) = xylobium.dledit.Action('roa_size_distribution_freq', ...
    @(t,m,e) dogbane.trial_processing.roa.plot_roa_size_distribution_freq(t), ...
    false, ...
    false);
actions(end+1) = xylobium.dledit.Action('roa_dur_distribution_freq', ...
    @(t,m,e) dogbane.trial_processing.roa.plot_roa_dur_distribution_freq(t), ...
    false, ...
    false);
actions(end+1) = xylobium.dledit.Action('roa_vol_distribution_freq', ...
    @(t,m,e) dogbane.trial_processing.roa.plot_roa_vol_distribution_freq(t), ...
    false, ...
    false);

%% Modifiers
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_distributions');
mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_heatmap_per_episode');
mods(end+1) = alyssum_v2.util.RecRigLoadVar('state_episodes');
mods(end+1) = alyssum_v2.util.RecRigLoadVar('inside_awakenings');
% mods(end+1) = alyssum_v2.util.TSeriesHasVar('roa_frequency_zscore');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'state_episodes';
initial_vars{end+1} = 'inside_awakenings';
initial_vars{end+1} = 'roa_heatmap_per_episode';
initial_vars{end+1} = 'roa_distributions';
% initial_vars{end+1} = 'roa_frequency_zscore';
%%
xylobium.dledit.Editor(trials, actions, initial_vars,mods);
end
