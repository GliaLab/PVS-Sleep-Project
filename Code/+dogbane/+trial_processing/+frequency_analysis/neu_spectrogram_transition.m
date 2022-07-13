function neu_spectrogram_transition(trial)
%%
tr = trial.rec_rig_trial;
ts = trial.tseries;

dt = ts.dt;
fs = 1/dt;

ts.clear_var('neu_spectrogram_transition');
%% Load

valid_transitions = {'rem','is','nrem','rem:awakening','nrem:awakening','is:awakening'};

tbl_transitions = tr.load_var('state_episodes_transitions');
tbl_transitions = tbl_transitions(ismember(tbl_transitions.State,valid_transitions),:);
% Remove short durations
tbl_transitions(tbl_transitions.StateDuration < 10,:) = [];

if isempty(tbl_transitions)
    return;
end

if ~ts.has_var('ca_signal_Gp_neu')
    return;
end

neuropil = ts.load_var('ca_signal_Gp_neu');
neuropil = reshape(neuropil,[],1);
neuropil = round(neuropil,2);
neuropil = neuropil / mode(neuropil) - 1;
%% Fix the stupid big letter naming of the columns

tbl_transitions.state = tbl_transitions.State;
tbl_transitions.state_duration = tbl_transitions.StateDuration;
tbl_transitions.state_start = tbl_transitions.StateStart;
tbl_transitions.state_end = tbl_transitions.StateEnd;

tbl_transitions.State = [];
tbl_transitions.StateDuration = [];
tbl_transitions.StateStart = [];
tbl_transitions.StateEnd = [];
tbl_transitions.PreviousState = [];
tbl_transitions.PreviousStateDuration = [];
tbl_transitions.PreviousStateStart = [];
tbl_transitions.PreviousStateEnd = [];
%%
% % The number of samples of the signals should be the same for every trial
% % when it is put into the spectrogram function so the output of every trial
% % has the same length. Instead of resampling the calcium signals to the
% % same Fs we just assume it is sampled at 30 Hz. As the sampling frequecy
% % is so close to 30 it should be fine, also resampling has intruduced
% % problems for us before. 
% fake_fs = 30;

t = (-round(30*fs):round(30*fs)) * dt;

transition_points = tbl_transitions.state_start;
trace_indices = ones(length(transition_points),1);

% Should probably update this function so it is a bit easier to use when
% there are only one trace. 
neuropil_transitions = begonia.processing.create_transition_traces( ...
    t, ...
    neuropil, ...
    trace_indices, ...
    transition_points)';

f = 0:0.1:15;

% tbl_transitions.f = repmat(f,height(tbl_transitions),1);
tbl_transitions.spectrogram = cell(height(tbl_transitions),1);
tbl_transitions.spectrogram_f = cell(height(tbl_transitions),1);
tbl_transitions.spectrogram_t = cell(height(tbl_transitions),1);

for i = 1:height(tbl_transitions)
    
    sig = neuropil_transitions(i,:);
    
%     pspectrum(sig,fs,'spectrogram','FrequencyLimits',[0.0,15],'FrequencyResolution',0.5,'OverlapPercent',0);
    [s,f,t] = spectrogram(sig,round(1*fs),round(0.8*fs),f,fs);
    s = abs(s);
    
    tbl_transitions.spectrogram{i} = s;
    tbl_transitions.spectrogram_t{i} = t;
    tbl_transitions.spectrogram_f{i} = f;
end

neu_spectrogram_transition = tbl_transitions;
% neu_spectrogram_transition

ts.save_var(neu_spectrogram_transition);
end

