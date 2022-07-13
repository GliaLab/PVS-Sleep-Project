function roa_in_endfeet_transitions(trial)
ts = trial.tseries;
tr = trial.rec_rig_trial;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;
%%
ts.clear_var('roa_in_endfeet_transitions');

if ~tr.has_var('state_episodes_transitions')
    return;
end

if ~ts.has_var('roa_in_endfeet')
    return;
end

%%
tbl_episodes = tr.load_var('state_episodes_transitions');
tbl_episodes(tbl_episodes.State == 'undefined',:) = [];

tbl_roa_endfeet = ts.load_var('roa_in_endfeet');

% indexing trick to help create an expanded table . 
I_roi = floor(1:1/height(tbl_episodes):height(tbl_roa_endfeet)+1)';
I_roi(end) = [];

roi_id = tbl_roa_endfeet.roi_id(I_roi);
roi_group = tbl_roa_endfeet.roi_group(I_roi);

% Indexing again.
I_ep = repmat(1:height(tbl_episodes),1,height(tbl_roa_endfeet))';
state = tbl_episodes.State(I_ep);
state_previous = tbl_episodes.PreviousState(I_ep);
state_duration = tbl_episodes.StateDuration(I_ep);
state_start = tbl_episodes.StateStart(I_ep);
state_end = tbl_episodes.StateEnd(I_ep);

% Create a time vector that has a constant number of samples (for every
% time this function is run), and also has the correct sampling rate. 
assumed_fs = 30;
t = -30*assumed_fs:30*assumed_fs;
t = t / fs;

roa_density_transitions = begonia.processing.create_transition_traces(t,tbl_roa_endfeet.roa_density_trace',I_roi,state_start)';
roa_frequency_transitions = begonia.processing.create_transition_traces(t,tbl_roa_endfeet.roa_frequency_trace',I_roi,state_start)';

roa_in_endfeet_transitions = table(roi_id,roi_group,state,state_previous,state_duration,state_start,state_end,roa_density_transitions,roa_frequency_transitions);

ts.save_var(roa_in_endfeet_transitions)
end

