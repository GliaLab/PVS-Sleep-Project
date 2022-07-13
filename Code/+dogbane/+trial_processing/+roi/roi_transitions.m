function roi_transitions(trial)
ts = trial.tseries;
tr = trial.rec_rig_trial;

dt = ts.dt;
fs = 1/dt;
%%
ts.clear_var('roi_transitions');

if ~tr.has_var('state_episodes_transitions')
    return;
end

if ~ts.has_var('roi_traces')
    return;
end

%%
tbl_episodes = tr.load_var('state_episodes_transitions');
tbl_episodes(tbl_episodes.State == 'undefined',:) = [];

roi_traces = ts.load_var('roi_traces');

% indexing trick to help create an expanded table . 
I_roi = floor(1:1/height(tbl_episodes):height(roi_traces)+1)';
I_roi(end) = [];

roi_id = roi_traces.roi_id(I_roi);
roi_group = roi_traces.roi_group(I_roi);

% Indexing again.
I_ep = repmat(1:height(tbl_episodes),1,height(roi_traces))';
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

df_f0 = begonia.processing.create_transition_traces(t,roi_traces.df_f0',I_roi,state_start)';

roi_transitions = table(roi_id,roi_group,state,state_previous,state_duration,state_start,state_end,df_f0);

ts.save_var(roi_transitions)
end

