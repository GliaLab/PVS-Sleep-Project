function roa_in_endfeet_states(trial)


ts = trial.tseries;
tr = trial.rec_rig_trial;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;
%%

ts.clear_var('roa_in_endfeet_states');

if ~tr.has_var('state_episodes')
    return;
end
if ~ts.has_var('roa_in_endfeet')
    return;
end
%%

tbl_episodes = tr.load_var('state_episodes_transitions');
tbl_episodes(tbl_episodes.State == 'undefined',:) = [];

tbl_roa_endfeet = ts.load_var('roa_in_endfeet');
%%

trace_length = size(tbl_roa_endfeet.roa_density_trace,2);

tbl_episodes.start_idx  = round(tbl_episodes.StateStart * fs) + 1;
tbl_episodes.end_idx    = round(tbl_episodes.StateEnd * fs);

o = struct;
cnt = 1;
for i = 1:height(tbl_episodes)
    st = tbl_episodes.start_idx(i);
    en = tbl_episodes.end_idx(i);
    
    if st > trace_length
        continue;
    end
    
    if en > trace_length
        en = trace_length;
    end
    
    for j = 1:height(tbl_roa_endfeet)
        o(cnt).state = tbl_episodes.State(i);
        o(cnt).state_duration = tbl_episodes.StateDuration(i);
        
        o(cnt).roi_group = tbl_roa_endfeet.roi_group(j);
        o(cnt).roi_id = tbl_roa_endfeet.roi_id(j);
        o(cnt).roa_freq = mean(tbl_roa_endfeet.roa_frequency_trace(j,st:en));
        o(cnt).roa_density = mean(tbl_roa_endfeet.roa_density_trace(j,st:en));
        cnt = cnt + 1;
    end
end

roa_in_endfeet_states = struct2table(o,'AsArray',true);
ts.save_var(roa_in_endfeet_states);
end

