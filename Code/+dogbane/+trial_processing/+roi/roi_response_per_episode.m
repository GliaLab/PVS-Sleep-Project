function roi_response_per_episode(trial)
tr = trial.rec_rig_trial;
ts = trial.tseries;

dt = ts.dt;
fs = 1/dt;

ts.clear_var('roi_response_per_episode');
%%
roi_traces = ts.load_var('roi_traces',[]);
if isempty(roi_traces)
    begonia.util.logging.vlog(1,'No roi_traces.');
    return;
end

%%

tbl_episodes = tr.load_var('state_episodes',[]);
if isempty(tbl_episodes)
    begonia.util.logging.vlog(1,'No state_episodes variable.');
    return
end

tbl_episodes(tbl_episodes.State == 'undefined',:) = [];

if isempty(tbl_episodes)
    begonia.util.logging.vlog(1,'Only undefined episodes.');
    return;
end

tbl_episodes.start_idx = round(tbl_episodes.StateStart * fs) + 1;
tbl_episodes.end_idx = round(tbl_episodes.StateEnd * fs);

L = size(roi_traces.df_f0,2);

o = struct;
cnt = 1;
for i = 1:height(tbl_episodes)
    st = tbl_episodes.start_idx(i);
    en = tbl_episodes.end_idx(i);

    if st >= L
        break;
    end
    if en > L
        en = L;
    end

    for j = 1:height(roi_traces)
        o(cnt).state = tbl_episodes.State(i);
        o(cnt).state_duration = tbl_episodes.StateDuration(i);
        o(cnt).episode_number = i;
        
        o(cnt).roi_id = roi_traces.roi_id(j);
        o(cnt).roi_group = roi_traces.roi_group(j);
        o(cnt).avg_response = mean(roi_traces.df_f0(j,st:en));
        
        cnt = cnt + 1;
    end
end

roi_response_per_episode = struct2table(o);
roi_response_per_episode.state = categorical(roi_response_per_episode.state);
roi_response_per_episode.roi_id = categorical(roi_response_per_episode.roi_id);
roi_response_per_episode.roi_group = categorical(roi_response_per_episode.roi_group);

ts.save_var(roi_response_per_episode);
end

