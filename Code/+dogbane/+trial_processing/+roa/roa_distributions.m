function roa_distributions(trial)

tr = trial.rec_rig_trial;
ts = trial.tseries;

%% Load 
roa_table       = ts.load_var('highpass_thresh_roa_table');
fov             = ts.load_var('roa_ignore_mask_area');
states          = tr.load_var('states');
state_episodes  = tr.load_var('state_episodes');

roa_table.dur = roa_table.roa_t_end - roa_table.roa_t_start;
%% Create a table of state durations.
[G,state] = findgroups(state_episodes.State);
state_duration = splitapply(@sum,state_episodes.StateDuration,G);
table_states = table(state,state_duration);
%% Add states to the roa_table
% Add columns to roa_table.
roa_table.state = categorical(repmat({'undefined'},height(roa_table),1));

% Create the indicies of the roa table. 
I_1 = 1:height(roa_table);
% Convert the event times into indices of states.
I_2 = round(roa_table.roa_t_start * states.states_fs) + 1;

% Remove events outside of the states trace in both index lists. 
I = I_2 > length(states.states_trace);
I_1(I) = [];
I_2(I) = [];

roa_table.state(I_1) = states.states_trace(I_2);
%% Calculate the distribution for each state, and once for all the states merged.

[G,state] = findgroups(roa_table.state);

roa_sizes_bin_edges = logspace(-2,6,8*3+1); % um^2
roa_dur_bin_edges   = logspace(-2,2,4*3+1); % s
roa_vol_bin_edges   = logspace(-2,4,6*3+1); % s

roa_sizes_N = splitapply(@(vec)histcounts(vec,roa_sizes_bin_edges), roa_table.roa_xy_size, G);
roa_dur_N = splitapply(@(vec)histcounts(vec,roa_dur_bin_edges), roa_table.dur, G);
roa_vol_N = splitapply(@(vec)histcounts(vec,roa_vol_bin_edges), roa_table.roa_vol_size, G);

roa_distributions = table(state,roa_sizes_N,roa_dur_N,roa_vol_N);
%% 
roa_sizes_bin_widths = diff(roa_sizes_bin_edges);
roa_dur_bin_widths = diff(roa_dur_bin_edges);
roa_vol_bin_widths = diff(roa_vol_bin_edges);

roa_distributions = innerjoin(table_states,roa_distributions);
roa_distributions.roa_sizes_bin_edges = repmat(roa_sizes_bin_edges,height(roa_distributions),1);
roa_distributions.roa_sizes_N_norm = roa_distributions.roa_sizes_N / fov ./ roa_distributions.state_duration ./ roa_sizes_bin_widths;
roa_distributions.roa_dur_bin_edges = repmat(roa_dur_bin_edges,height(roa_distributions),1);
roa_distributions.roa_dur_N_norm = roa_distributions.roa_dur_N / fov ./ roa_distributions.state_duration ./ roa_dur_bin_widths;
roa_distributions.roa_vol_bin_edges = repmat(roa_vol_bin_edges,height(roa_distributions),1);
roa_distributions.roa_vol_N_norm = roa_distributions.roa_vol_N / fov ./ roa_distributions.state_duration ./ roa_vol_bin_widths;
roa_distributions.fov_area = repmat(fov,height(roa_distributions),1);
%%
ts.save_var(roa_distributions);
end

