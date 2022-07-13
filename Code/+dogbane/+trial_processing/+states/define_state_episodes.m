function state_episodes = define_state_episodes(trial,states_var_name)
states = trial.load_var(states_var_name);
states_fs = states.states_fs;
states_trace = states.states_trace;

%% Define columns. 
State = categorical(cell(0));
StateDuration = [];
StateStart = [];
StateEnd = [];

%% Gather data
row = 1;

state_cats = categories(states_trace);

for idx_state = 1:length(state_cats)
    state = state_cats{idx_state};
    [u,d] = begonia.util.consecutive_stages(states_trace == state);

    for idx_episode = 1:length(u)
        dur = d(idx_episode) - u(idx_episode) + 1;
        dur = dur/states_fs;

        t_start = u(idx_episode) - 1;
        t_start = t_start/states_fs;

        t_end = d(idx_episode);
        t_end = t_end/states_fs;

        State(row,1) = state;
        StateDuration(row,1) = dur;
        StateStart(row,1) = t_start;
        StateEnd(row,1) = t_end;

        row = row + 1;
    end
end

state_episodes = table(State,StateDuration,StateStart,StateEnd);

state_episodes = sortrows(state_episodes,'StateStart');

%% Add data about previous episode
tbl_copy = circshift(state_episodes,1);

state_episodes.PreviousState = tbl_copy.State;
state_episodes.PreviousStateDuration = tbl_copy.StateDuration;
state_episodes.PreviousStateStart = tbl_copy.StateStart;
state_episodes.PreviousStateEnd = tbl_copy.StateEnd;

% Remove the previous sleep episode data from the start of each trial.
state_episodes.PreviousState(1) = '';
state_episodes.PreviousStateDuration(1) = nan;
state_episodes.PreviousStateStart(1) = nan;
state_episodes.PreviousStateEnd(1) = nan;
end

