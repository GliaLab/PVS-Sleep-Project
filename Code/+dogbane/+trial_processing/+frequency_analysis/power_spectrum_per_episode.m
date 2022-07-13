function power_spectrum_per_episode(trial)
%%
tr = trial.rec_rig_trial;
ts = trial.tseries;

dt = ts.dt;
fs = 1/dt;

ts.clear_var('power_spectrum_per_episode');

%%
doughnut_trace = ts.load_var('neuron_doughnuts_merged',[]);
if ~isempty(doughnut_trace)
    doughnut_trace = round(doughnut_trace,1);

    doughnut_trace = doughnut_trace / mode(doughnut_trace) - 1;

    doughnut_trace(end-10:end) = [];
    
end
%%

ca_signal_Gp_neu = ts.load_var('ca_signal_Gp_neu',[]);
if ~isempty(ca_signal_Gp_neu)
    ca_signal_Gp_neu = double(ca_signal_Gp_neu);
    ca_signal_Gp_neu = round(ca_signal_Gp_neu,1);

    ca_signal_Gp_neu = ca_signal_Gp_neu / mode(ca_signal_Gp_neu) - 1;

    ca_signal_Gp_neu(end-10:end) = [];
end
%%

if isempty(doughnut_trace) && isempty(ca_signal_Gp_neu)
    return;
end

%% Calculate power spectrum per episode
tbl_states = tr.load_var('state_episodes');

tbl_states.start_idx = round(tbl_states.StateStart * fs) + 1;
tbl_states.end_idx = round(tbl_states.StateEnd * fs);

o = struct;
cnt = 1;
for i = 1:height(tbl_states)
    %%
    if tbl_states.StateDuration(i) < 10
        continue;
    end

    o(cnt).state = tbl_states.State(i);
    o(cnt).state_start = tbl_states.StateStart(i);
    o(cnt).state_end = tbl_states.StateEnd(i);
    o(cnt).state_duration = tbl_states.StateDuration(i);
    %% 
    st = tbl_states.start_idx(i);
    en = tbl_states.end_idx(i);
    %% doughnut
    if isempty(doughnut_trace) || st > length(doughnut_trace)
        o(cnt).doughnut_spectrum = {[]};
        o(cnt).doughnut_freq = {[]};
        o(cnt).doughnut_low_delta = nan;
        o(cnt).doughnut_high_delta = nan;
        o(cnt).doughnut_delta = nan;
        o(cnt).doughnut_theta = nan;
        o(cnt).doughnut_sigma = nan;
    else
        
        % Get the trace in the episode.
        if en > length(doughnut_trace)
            sig = doughnut_trace(st:length(doughnut_trace));
        else
            sig = doughnut_trace(st:en);
        end

    
        [p,f] = pspectrum(sig,fs,'power','FrequencyLimits',[0.0,15],'FrequencyResolution',0.5);

        % Resample so all trials have the same length and frequency resolution.
        f_df = 0.01; % Calculate the power for every 0.01 Hz
        f_fs = 1/f_df; 
        [p,f] = resample(p,f,f_fs);
        % End at 14.8 Hz
        f_cut = (14.8 - f(1))/f_df + 1;
        f = f(1:f_cut);
        p = p(1:f_cut);

        o(cnt).doughnut_spectrum = {p'};
        o(cnt).doughnut_freq = {f'};
        o(cnt).doughnut_low_delta   = bandpower(sig,fs,[0.5,2]);
        o(cnt).doughnut_high_delta  = bandpower(sig,fs,[2,4]);
        o(cnt).doughnut_delta       = bandpower(sig,fs,[0.5,4]);
        o(cnt).doughnut_theta       = bandpower(sig,fs,[5,9]);
        o(cnt).doughnut_sigma       = bandpower(sig,fs,[9,14]);
    end
    %% gliopil neuron trace
    if isempty(ca_signal_Gp_neu) || st > length(ca_signal_Gp_neu)
        o(cnt).Gp_neu_spectrum = {[]};
        o(cnt).Gp_neu_freq = {[]};
        o(cnt).Gp_neu_low_delta = nan;
        o(cnt).Gp_neu_high_delta = nan;
        o(cnt).Gp_neu_delta = nan;
        o(cnt).Gp_neu_theta = nan;
        o(cnt).Gp_neu_sigma = nan;
    else
        
        % Get the trace in the episode.
        if en > length(ca_signal_Gp_neu)
            sig = ca_signal_Gp_neu(st:length(ca_signal_Gp_neu));
        else
            sig = ca_signal_Gp_neu(st:en);
        end

    
        [p,f] = pspectrum(sig,fs,'power','FrequencyLimits',[0.0,15],'FrequencyResolution',0.5);

        % Resample so all trials have the same length and frequency resolution.
        f_df = 0.01; % Calculate the power for every 0.01 Hz
        f_fs = 1/f_df; 
        [p,f] = resample(p,f,f_fs);
        % End at 14.8 Hz
        f_cut = (14.8 - f(1))/f_df + 1;
        f = f(1:f_cut);
        p = p(1:f_cut);

        o(cnt).Gp_neu_spectrum = {p'};
        o(cnt).Gp_neu_freq = {f'};
        o(cnt).Gp_neu_low_delta   = bandpower(sig,fs,[0.5,2]);
        o(cnt).Gp_neu_high_delta  = bandpower(sig,fs,[0.5,2]);
        o(cnt).Gp_neu_delta       = bandpower(sig,fs,[0.5,4]);
        o(cnt).Gp_neu_theta       = bandpower(sig,fs,[5,9]);
        o(cnt).Gp_neu_sigma       = bandpower(sig,fs,[9,14]);
    end
    %%
    cnt = cnt + 1;
end
%% Save table
power_spectrum_per_episode = struct2table(o,'AsArray',true);
power_spectrum_per_episode.state = categorical(power_spectrum_per_episode.state);

ts.save_var(power_spectrum_per_episode);

end

