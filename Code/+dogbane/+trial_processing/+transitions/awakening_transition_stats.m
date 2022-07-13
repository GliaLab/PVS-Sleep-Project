function awakening_transition_stats(trial)

tr = trial.rec_rig_trial;
ts = trial.tseries;

dt = ts.dt;
fs = 1/dt;

ts.clear_var('awakening_transition_stats');
%% episodes

tbl_transitions = tr.load_var('state_episodes_transitions');

if ~any(ismember(tbl_transitions.State,{'rem:awakening','nrem:awakening','is:awakening'}))
    return;
end

% Remove undefined so the sleep episodes are next to the awakening episodes
% in the table (hopefully)
tbl_transitions(tbl_transitions.State == 'undefined',:) = [];

%% roa frequency
roa_frequency_trace = ts.load_var('highpass_thresh_roa_frequency_trace');
    
% Filter
tau = 0.25;
filter_t = (-tau*10:dt:tau*10)';
filter = filter_t.*exp(-filter_t/tau);
filter(1:floor(length(filter)/2)) = 0;
filter = filter ./ sum(filter);

roa_frequency_trace = convn(roa_frequency_trace,filter','same');

%% eeg
eeg_norm = tr.load_var('eeg_norm');
eeg_fs = tr.load_var('eeg_norm_fs');
% eeg_dt = 1/eeg_fs;

% t_eeg_start = round(-15 * eeg_fs);
% t_eeg_end = round(15 * eeg_fs);

%% Define variables
% Assume the sampling frequency is 30 so we dont have to resample and all
% trials have equal vector lengths. 
assumed_fs = 30;
assumed_dt = 1/assumed_fs;

t_start = round(-15 * assumed_fs);
t_end = round(15 * assumed_fs);

t = (t_start:t_end) * assumed_dt;

% z-score the traces based on the period -15 to -5 seconds.
I_norm = begonia.util.val2idx(t,-15):begonia.util.val2idx(t,-5);

% Define the index where we start looking for the upstroke.
check_start = begonia.util.val2idx(t,-5);

% Threshold in standard deviations to find upstroke.
threshold = 2.5;
%% 
o = struct;
cnt = 1;
for i = 1:height(tbl_transitions)
    if ~ismember(tbl_transitions.State(i),{'rem:awakening','nrem:awakening','is:awakening'})
        continue;
    end
    
    st = round(tbl_transitions.StateStart(i) * fs) + 1;
    
    %% trace
    idx_1 = st + t_start;
    idx_2 = st + t_end;
    if idx_1 < 1
        nan_pad = 1 - idx_1;
        trace = [nan(1,nan_pad),roa_frequency_trace(1:idx_2)];
    elseif idx_2 > length(roa_frequency_trace)
        nan_pad = idx_2 - length(roa_frequency_trace);
        trace = [roa_frequency_trace(idx_1:end),nan(1,nan_pad)];
    else
        trace = roa_frequency_trace(idx_1:idx_2);
    end
    
    %% zscore
    mu = mean(trace(I_norm));
    sigma = std(trace(I_norm));
    
    trace_z = (trace - mu) / sigma;
    %% find onset
    trace_thresh = trace_z > threshold;
    
    upstrokes = diff(trace_thresh(check_start:end)) == 1;
    upstrokes = find(upstrokes) + check_start - 1;
    if isempty(upstrokes)
        onset = nan;
    else
        % Pick the first upstroke
        onset = t(upstrokes(1));
    end
    %% previous episode stats
    if i ~= 1
        previous_state_duration = tbl_transitions.StateDuration(i-1);

        % eeg power of the previous episode
        idx_1_eeg = round(tbl_transitions.StateStart(i-1) * eeg_fs) + 1;
        idx_2_eeg = round(tbl_transitions.StateEnd(i-1) * eeg_fs);

        eeg_trace = eeg_norm(idx_1_eeg:idx_2_eeg);

        eeg_delta = bandpower(eeg_trace,eeg_fs,[0.5,4]);
        eeg_theta = bandpower(eeg_trace,eeg_fs,[5,9]);
        eeg_sigma = bandpower(eeg_trace,eeg_fs,[9,16]);
    else
        previous_state_duration = nan;
        eeg_delta = nan;
        eeg_theta = nan;
        eeg_sigma = nan;
    end
    
    %% save
    o(cnt).state = tbl_transitions.State(i);
    o(cnt).t = t;
    o(cnt).roa_frequency_trace = trace;
    o(cnt).roa_frequency_trace_zscore = trace_z;
    o(cnt).onset = onset;
    o(cnt).previous_state_duration = previous_state_duration;
    o(cnt).previous_eeg_delta = eeg_delta;
    o(cnt).previous_eeg_theta = eeg_theta;
    o(cnt).previous_eeg_sigma = eeg_sigma;
    
    cnt = cnt + 1;
end

awakening_transition_stats = struct2table(o,'AsArray',true);
% awakening_transition_stats

ts.save_var(awakening_transition_stats)
end

