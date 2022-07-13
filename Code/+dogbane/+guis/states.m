function states(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Load manual scoring', ...
    @(d,m,e) dogbane.trial_processing.manual_scoring.load_sleep(d), ...
    false, true);

actions(end+1) = xylobium.dledit.Action('Define states', ...
    @(d,m,e) dogbane.trial_processing.states.save(d), ...
    true, false);

actions(end+1) = xylobium.dledit.Action('Plot states', ...
    @(d,m,e) dogbane.trial_processing.states.plot_states(d), ...
    false, false);

actions(end+1) = xylobium.dledit.Action('Count sleep transitions', ...
    @(d,m,e) dogbane.trial_processing.states.count_sleep_and_awakenings(d), ...
    true, false);

actions(end+1) = xylobium.dledit.Action('Define microarousals', ...
    @(d,m,e) dogbane.trial_processing.states.define_microarousals(d), ...
    true, false);

actions(end+1) = xylobium.dledit.Action('Inside awakenings', ...
    @(d,m,e) dogbane.trial_processing.inside_awakenings.run(d), ...
    true, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.RecRigHasVar('sleep_stages');
mods(end+1) = alyssum_v2.util.RecRigHasVar('state_episodes');
mods(end+1) = alyssum_v2.util.RecRigHasVar('sleep_and_awakenings');
mods(end+1) = alyssum_v2.util.RecRigHasVar('microarousals');
mods(end+1) = alyssum_v2.util.RecRigHasVar('inside_awakenings');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'name';
initial_vars{end+1} = 'sleep_stages';
initial_vars{end+1} = 'state_episodes';
initial_vars{end+1} = 'sleep_and_awakenings';
initial_vars{end+1} = 'microarousals';
initial_vars{end+1} = 'inside_awakenings';
%%
xylobium.dledit.Editor(trials,actions,initial_vars,mods);

end

