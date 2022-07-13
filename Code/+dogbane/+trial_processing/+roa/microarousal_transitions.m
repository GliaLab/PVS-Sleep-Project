function microarousal_transitions(trial)

ts = trial.tseries;
tr = trial.rec_rig_trial;

dx = ts.dx;
dt = ts.dt;
fs = 1/dt;

ts.clear_var('microarousal_transitions');
%% Load microarousals
tbl = tr.load_var('microarousals',[]);
if isempty(tbl); return; end
tbl = tbl(tbl.state == 'microarousal',:);

state = tbl.state;
state_duration = tbl.state_duration;

%% Load traces
roa_frequency = ts.load_var('highpass_thresh_roa_frequency_trace');

whisker = tr.load_var('camera_whisker');
whisker = reshape(whisker,[],1);
camera_fs = tr.load_var('camera_fs');

eeg = tr.load_var('eeg_norm');
emg = tr.load_var('emg');
eeg_fs = tr.load_var('eeg_fs');
emg_fs = tr.load_var('emg_fs');
assert(eeg_fs == emg_fs);
assert(eeg_fs == 512);
assert(length(eeg) == length(emg));

eeg = reshape(eeg,[],1);
emg = reshape(emg,[],1);

eeg = double(eeg);
emg = double(emg);

% eeg power
% Band in Hz. 
band = [1,15];
% Filter
band = band * 2 / eeg_fs;
[b,a] = butter(2,band,'bandpass');
bp = filtfilt(b, a, eeg);
% Envelope hilbert
eeg = hilbert(bp);
eeg = abs(eeg).^2;

% emg
emg = abs(emg);
%% Resample
new_fs = 30;

t = (0:length(roa_frequency)-1)/fs;
roa_frequency = resample(roa_frequency,t,new_fs);

t = (0:length(whisker)-1)/camera_fs;
whisker = resample(whisker,t,new_fs);

t = (0:length(eeg)-1)/eeg_fs;
eeg = resample(eeg,t,new_fs);

t = (0:length(emg)-1)/emg_fs;
emg = resample(emg,t,new_fs);


%% Extract transitions
t = -30*new_fs:30*new_fs;
t = t / new_fs;

roa = begonia.processing.extract_transitions( ...
    t,roa_frequency,tbl.state_start)';
whisker = begonia.processing.extract_transitions( ...
    t,whisker,tbl.state_start)';
eeg = begonia.processing.extract_transitions( ...
    t,eeg,tbl.state_start)';
emg = begonia.processing.extract_transitions( ...
    t,emg,tbl.state_start)';

% roa_transition_strict = begonia.processing.extract_transitions_strict( ...
%     t,roa_frequency, ...
%     tbl.state_start, ...
%     tbl.state_start+t(1), ...
%     tbl.state_end)';
%% Neuron trace
neuron = ts.load_var('ca_signal_neurons_subtracted',[]);
if isempty(neuron) || isempty(neuron.Data)
    neuron = nan(length(state),length(t));
else
    neuron_fs = 1/neuron.TimeInfo.Increment;
    neuron = mean(neuron.Data,2);
    
    t = (0:length(neuron)-1)/neuron_fs;
    neuron = resample(neuron,t,new_fs);
    
    t = -30*new_fs:30*new_fs;
    t = t / new_fs;
    neuron = begonia.processing.extract_transitions( ...
        t,neuron,tbl.state_start)';
    
end
%%

microarousal_transitions = table(state, state_duration, ...
    roa, eeg, emg, whisker,neuron);

ts.save_var(microarousal_transitions);
end

