function save(trial)
trial = trial.rec_rig_trial;

dogbane.trial_processing.states.define_states(trial);

state_episodes = dogbane.trial_processing.states.define_state_episodes(trial,'states');
state_episodes_sleep_wake = dogbane.trial_processing.states.define_state_episodes(trial,'states_sleep_wake');
state_episodes_transitions = dogbane.trial_processing.states.define_state_episodes(trial,'states_transitions');
state_episodes_short_quiet = dogbane.trial_processing.states.define_state_episodes(trial,'states_short_quiet');

trial.save_var(state_episodes);
trial.save_var(state_episodes_sleep_wake);
trial.save_var(state_episodes_transitions);
trial.save_var(state_episodes_short_quiet);

end

