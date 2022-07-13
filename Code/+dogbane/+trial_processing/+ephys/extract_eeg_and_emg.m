function extract_eeg_and_emg(trial)

tr = trial.rec_rig_trial;

if isempty(tr)
    return;
end

tr.clear_var('eeg');
tr.clear_var('eeg_fs');
tr.clear_var('emg');
tr.clear_var('emg_fs');
    
eeg_idx = tr.load_var('eeg_idx');
emg_idx = tr.load_var('emg_idx');

ephys = tr.load_var('ephys_down');

eeg = ephys.Data(:,eeg_idx)';
emg = ephys.Data(:,emg_idx)';

eeg_dt = ephys.TimeInfo.Increment;
emg_dt = ephys.TimeInfo.Increment;

eeg_fs = 1/eeg_dt;
emg_fs = 1/emg_dt;

tr.save_var(eeg);
tr.save_var(eeg_fs);
tr.save_var(emg);
tr.save_var(emg_fs);
end

