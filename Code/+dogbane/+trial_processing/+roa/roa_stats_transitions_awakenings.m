function roa_stats_transitions_awakenings(trial)
ts = trial.tseries;
tr = trial.rec_rig_trial;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

ts.clear_var('roa_stats_transitions_awakenings');

if ~tr.has_var('state_episodes_transitions')
    return;
end

if ~ts.has_var('roa_size_trace')
    return;
end
%%
roa_size_trace = ts.load_var('roa_size_trace');
roa_volume_trace = ts.load_var('roa_volume_trace');
roa_duration_trace = ts.load_var('roa_duration_trace');

%% Resample
N = length(roa_size_trace);
t = (0:N-1)/fs;
new_fs = 30;
roa_size_trace = resample(roa_size_trace,t,new_fs);
roa_volume_trace = resample(roa_volume_trace,t,new_fs);
roa_duration_trace = resample(roa_duration_trace,t,new_fs);
%% Extract transitions
tbl_episodes = tr.load_var('state_episodes_transitions');
tbl_episodes(tbl_episodes.State == 'undefined',:) = [];
% Only include awakenings. 
I = ismember(tbl_episodes.State,{'rem:awakening','nrem:awakening','is:awakening'});
tbl_episodes = tbl_episodes(I,:);

if isempty(tbl_episodes)
    begonia.util.logging.vlog(1,'Trial does not include awakenings.');
    return;
end
%%
state = tbl_episodes.State;
state_previous = tbl_episodes.PreviousState;
state_duration = tbl_episodes.StateDuration;
state_start = tbl_episodes.StateStart;
state_end = tbl_episodes.StateEnd;

t = -30*new_fs:30*new_fs;
t = t / new_fs;

roa_size_transition = begonia.processing.extract_transitions( ...
    t,roa_size_trace, ...
    state_start)';

roa_size_transition_strict = begonia.processing.extract_transitions_strict( ...
    t,roa_size_trace, ...
    state_start, ...
    state_start+t(1), ...
    state_end)';

roa_volume_transition = begonia.processing.extract_transitions( ...
    t, roa_volume_trace, ...
    state_start)';

roa_volume_transition_strict = begonia.processing.extract_transitions_strict( ...
    t,roa_volume_trace, ...
    state_start, ...
    state_start+t(1), ...
    state_end)';

roa_duration_transition = begonia.processing.extract_transitions( ...
    t, roa_duration_trace, ...
    state_start)';

roa_duration_transition_strict = begonia.processing.extract_transitions_strict( ...
    t,roa_duration_trace, ...
    state_start, ...
    state_start+t(1), ...
    state_end)';

roa_stats_transitions_awakenings = table(state,state_duration,state_start, ...
    state_end, ...
    roa_size_transition,roa_volume_transition, roa_duration_transition,...
    roa_size_transition_strict,roa_volume_transition_strict, roa_duration_transition_strict);

ts.save_var(roa_stats_transitions_awakenings);
end

