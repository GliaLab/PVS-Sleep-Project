function eeg_emg_transitions(trial)
tr = trial.rec_rig_trial;
%%
tr.clear_var('eeg_emg_transitions');

if ~tr.has_var('state_episodes')
    return;
end

if ~tr.has_var('eeg')
    return;
end

%%
eeg_all = tr.load_var('eeg_norm');
emg_all = tr.load_var('emg');
eeg_fs = tr.load_var('eeg_fs');
emg_fs = tr.load_var('emg_fs');
assert(eeg_fs == emg_fs);
assert(eeg_fs == 512);
assert(length(eeg_all) == length(emg_all));

eeg_all = double(eeg_all);
emg_all = double(emg_all);

eeg_all = reshape(eeg_all,[],1);
emg_all = reshape(emg_all,[],1);
%% eeg power
% Band in Hz. 
band = [1,15];

% Convert to unitless nyquist frequency thing.
band = band * 2 / eeg_fs;
[b,a] = butter(2,band,'bandpass');
bp = filtfilt(b, a, eeg_all);

% Envelope hilbert magic
eeg_all = hilbert(bp);
eeg_all = abs(eeg_all).^2;
%% emg
emg_all = abs(emg_all);

%% resample to 30 Hz
ephys_t = (0:length(eeg_all)-1)/eeg_fs;
fs = 30;
eeg_all = resample(eeg_all,ephys_t,fs);
emg_all = resample(emg_all,ephys_t,fs);
%%
tbl_episodes = tr.load_var('state_episodes');
tbl_episodes(tbl_episodes.State == 'undefined',:) = [];

state = tbl_episodes.State;
state_duration = tbl_episodes.StateDuration;
state_start = tbl_episodes.StateStart;
state_end = tbl_episodes.StateEnd;
 
t = (-30*fs:30*fs)/fs;

eeg = begonia.processing.extract_transitions( ...
    t,eeg_all, ...
    tbl_episodes.StateStart)';
eeg_strict = begonia.processing.extract_transitions_strict( ...
    t,eeg_all, ...
    tbl_episodes.StateStart, ...
    tbl_episodes.StateStart+t(1), ...
    tbl_episodes.StateEnd)';
emg = begonia.processing.extract_transitions( ...
    t,emg_all, ...
    tbl_episodes.StateStart)';
emg_strict = begonia.processing.extract_transitions_strict( ...
    t,emg_all, ...
    tbl_episodes.StateStart, ...
    tbl_episodes.StateStart+t(1), ...
    tbl_episodes.StateEnd)';

eeg_emg_transitions = table(state,state_duration,state_start,state_end, ...
    eeg, ...
    eeg_strict, ...
    emg, ...
    emg_strict);

tr.save_var(eeg_emg_transitions)
end

