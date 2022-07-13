function ephys(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('load manual scoring', ...
    @(d,m,e) dogbane.trial_processing.manual_scoring.load_sleep(d), ...
    true, true);
actions(end+1) = xylobium.dledit.Action('ephys', ...
    @(d,m,e) yucca.mod.ephys.write_vars([d.rec_rig_trial]), ...
    false, true);
actions(end+1) = xylobium.dledit.Action('Extract eeg and emg', ...
    @(d,m,e) dogbane.trial_processing.ephys.extract_eeg_and_emg(d), ...
    true, false);
actions(end+1) = xylobium.dledit.Action('eeg/emg transitions', ...
    @(d,m,e) dogbane.trial_processing.ephys.eeg_emg_transitions(d), ...
    true, false);
% actions(end+1) = xylobium.dledit.Action('eeg/emg transitions strict', ...
%     @(d,m,e) dogbane.trial_processing.ephys.eeg_emg_transitions_srict(d), ...
%     true, false);
% actions(end+1) = xylobium.dledit.Action('Compare old new eeg norm', ...
%     @(d,m,e) dogbane.trial_processing.ephys.compare_old_new_eeg_norm(d), ...
%     true, false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.RecRigHasVar('video_region_names');
mods(end+1) = alyssum_v2.util.RecRigHasVar('ephys');
mods(end+1) = alyssum_v2.util.RecRigHasVar('ephys_down');
mods(end+1) = alyssum_v2.util.RecRigHasVar('eeg_norm');
mods(end+1) = alyssum_v2.util.RecRigHasVar('emg');
mods(end+1) = alyssum_v2.util.RecRigHasVar('eeg_emg_transitions');
%%
initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'name';
initial_vars{end+1} = 'ephys';
initial_vars{end+1} = 'ephys_down';
initial_vars{end+1} = 'eeg_norm';
initial_vars{end+1} = 'emg';
initial_vars{end+1} = 'eeg_emg_transitions';
%%
xylobium.dledit.Editor(trials,actions,initial_vars,mods);

end

