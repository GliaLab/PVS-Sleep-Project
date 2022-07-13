function tbl = roa_per_episode(tm,state_variable)
if nargin < 2
    state_variable = 'state_episodes';
end

trials = tm.get_trials();

o = struct;
cnt = 1;

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,'roa_per_episode %d/%d',i,length(trials));

    tr = trials(i).rec_rig_trial;
    ts = trials(i).tseries;

    dt = ts.dt;
    fs = 1/dt;
    %% Load vars
    nan_trace = nan(size(0:dt:seconds(ts.duration)));
    
    roa_frequency_trace             = ts.load_var('roa_frequency_trace',nan_trace);
    roa_density_trace               = ts.load_var('roa_density_trace',nan_trace);
    highpass_roa_frequency_trace    = ts.load_var('highpass_roa_frequency_trace',nan_trace);
    highpass_roa_density_trace      = ts.load_var('highpass_roa_density_trace',nan_trace);
    highpass_thresh_roa_frequency_trace    = ts.load_var('highpass_thresh_roa_frequency_trace',nan_trace);
    highpass_thresh_roa_density_trace      = ts.load_var('highpass_thresh_roa_density_trace',nan_trace);
    
    fov = ts.load_var('roa_ignore_mask_area',[]);
    if isempty(fov)
        continue;
    end
    %%
    tbl_states = tr.load_var(state_variable);
    
    tbl_states.start_idx = round(tbl_states.StateStart * fs) + 1;
    tbl_states.end_idx = round(tbl_states.StateEnd * fs);
    
    shortest_trace = [...
        length(roa_frequency_trace), ...
        length(roa_density_trace), ...
        length(highpass_roa_frequency_trace), ...
        length(highpass_roa_density_trace) ...
        length(highpass_thresh_roa_frequency_trace), ...
        length(highpass_thresh_roa_density_trace)];
    shortest_trace = min(shortest_trace);

    for j = 1:height(tbl_states)
        st = tbl_states.start_idx(j);
        en = tbl_states.end_idx(j);
        
        if en > shortest_trace
            en = shortest_trace;
        end
        
        o(cnt).ts_uuid = ts.uuid;
        o(cnt).state = tbl_states.State(j);
        o(cnt).state_duration = tbl_states.StateDuration(j);
        o(cnt).state_start = tbl_states.StateStart(j);
        o(cnt).state_end = tbl_states.StateEnd(j);
        
        o(cnt).roa_freq = mean(roa_frequency_trace(st:en));
        o(cnt).roa_density = mean(roa_density_trace(st:en));
        o(cnt).roa_count = sum(roa_frequency_trace(st:en)) * dt * fov;
        
        o(cnt).highpass_roa_freq = mean(highpass_roa_frequency_trace(st:en));
        o(cnt).highpass_roa_density = mean(highpass_roa_density_trace(st:en));
        o(cnt).highpass_roa_count = sum(highpass_roa_frequency_trace(st:en)) * dt * fov;
        
        o(cnt).highpass_thresh_roa_freq = mean(highpass_thresh_roa_frequency_trace(st:en));
        o(cnt).highpass_thresh_roa_density = mean(highpass_thresh_roa_density_trace(st:en));
        o(cnt).highpass_thresh_roa_count = sum(highpass_thresh_roa_frequency_trace(st:en)) * dt * fov;
        
        cnt = cnt + 1;
    end
end

tbl = struct2table(o);
tbl.ts_uuid = categorical(tbl.ts_uuid);
%%
tbl_ids = dogbane.tables.other.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);

tbl_ts_data = dogbane.tables.other.tseries_metadata(tm);
tbl_ts_data = tbl_ts_data(:,{'ts_uuid','dx','dx_squared','optical_zoom'});
tbl = innerjoin(tbl,tbl_ts_data);
end

