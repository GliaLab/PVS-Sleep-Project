function roa_transitions(trial)

ts = trial.tseries;
tr = trial.rec_rig_trial;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

ts.clear_var('roa_transitions');

tbl_episodes = tr.load_var('state_episodes');
tbl_episodes(tbl_episodes.State == 'undefined',:) = [];

state = tbl_episodes.State;
state_start = tbl_episodes.StateStart;
state_end = tbl_episodes.StateEnd;
state_duration = tbl_episodes.StateDuration;

roa_frequency = ts.load_var('highpass_thresh_roa_frequency_trace');

% Create a time vector that has a constant number of samples (for every
% time this function is run), and also has the correct sampling rate. 
assumed_fs = 30;
t = -30*assumed_fs:30*assumed_fs;
t = t / fs;

roa_transition_start = begonia.processing.extract_transitions( ...
    t,roa_frequency,tbl_episodes.StateStart)';

roa_transition_end = begonia.processing.extract_transitions( ...
    t,roa_frequency,tbl_episodes.StateEnd)';

roa_transition_strict_start = begonia.processing.extract_transitions_strict( ...
    t,roa_frequency, ...
    tbl_episodes.StateStart, ...
    tbl_episodes.StateStart+t(1), ...
    tbl_episodes.StateEnd)';

roa_transition_strict_end = begonia.processing.extract_transitions_strict( ...
    t,roa_frequency, ...
    tbl_episodes.StateEnd, ...
    tbl_episodes.StateStart, ...
    tbl_episodes.StateEnd+t(end))';

roa_transitions = table(state, state_duration,state_start,state_end, ...
    roa_transition_start, ...
    roa_transition_end, ...
    roa_transition_strict_start, ...
    roa_transition_strict_end);

ts.save_var(roa_transitions);
end

