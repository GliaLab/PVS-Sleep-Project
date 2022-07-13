function tbl = events_per_episode(tm)
trials = tm.get_trials();

o = struct;
cnt = 1;

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,'aqua_events_per_episode %d/%d',i,length(trials));

    tr = trials(i).rec_rig_trial;
    ts = trials(i).tseries;
    %% Load vars
    aqua_data = ts.load_var('aqua_data',[]);
    
    if isempty(aqua_data)
        continue;
    end
    
    fs = aqua_data.fs;
    fov = aqua_data.fov;
    trace = aqua_data.frequency_trace;
    trace_length = length(trace);
    
    %%
    tbl_states = tr.load_var('state_episodes');
    
    tbl_states.start_idx = round(tbl_states.StateStart * fs) + 1;
    tbl_states.end_idx = round(tbl_states.StateEnd * fs);

    for j = 1:height(tbl_states)
        st = tbl_states.start_idx(j);
        en = tbl_states.end_idx(j);
        
        if st >= trace_length
            break;
        end
        
        if en > trace_length
            en = trace_length;
        end
        
        o(cnt).ts_uuid = ts.uuid;
        o(cnt).state = tbl_states.State(j);
        o(cnt).state_duration = tbl_states.StateDuration(j);
        o(cnt).state_start = tbl_states.StateStart(j);
        o(cnt).state_end = tbl_states.StateEnd(j);
        
        o(cnt).freq = mean(trace(st:en)) / fov * fs;
        o(cnt).event_count = sum(trace(st:en));
        
        cnt = cnt + 1;
    end
end

tbl = struct2table(o);
tbl.ts_uuid = categorical(tbl.ts_uuid);

tbl(tbl.state == 'undefined',:) = [];
%%
tbl_ids = dogbane.tables.other.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);

tbl_ts_data = dogbane.tables.other.tseries_metadata(tm);
tbl_ts_data = tbl_ts_data(:,{'ts_uuid','dx','dx_squared','optical_zoom'});
tbl = innerjoin(tbl,tbl_ts_data);

end

