function camera(tm)

trials = tm.get_trials();
%%
actions = xylobium.dledit.Action.empty();
actions(end+1) = xylobium.dledit.Action('Configure Camera', ...
    @(d,m,e) yucca.mod.camera_regions.configure([d.rec_rig_trial]), ...
    false, ...
    true);
actions(end+1) = xylobium.dledit.Action('Run Camera', ...
    @(d,m,e) yucca.mod.camera_regions.write_vars([d.rec_rig_trial]), ...
    true, ...
    false);
actions(end+1) = xylobium.dledit.Action('Whisker/Wheel traces', ...
    @(d,m,e) dogbane.trial_processing.camera.whisker_wheel_traces(d), ...
    true, ...
    false);
actions(end+1) = xylobium.dledit.Action('Whisker/Wheel transitions', ...
    @(d,m,e) dogbane.trial_processing.camera.whisker_wheel_transitions(d), ...
    true, ...
    false);
%%
mods = alyssum_v2.util.RecRigHasVar.empty();
mods(end+1) = alyssum_v2.util.RecRigHasVar('video_region_names');
mods(end+1) = alyssum_v2.util.RecRigHasVar('camera_regions');
mods(end+1) = alyssum_v2.util.RecRigHasVar('camera_wheel');
mods(end+1) = alyssum_v2.util.RecRigHasVar('camera_whisker');
mods(end+1) = alyssum_v2.util.RecRigLoadVar('camera_fs');
mods(end+1) = alyssum_v2.util.RecRigHasVar('whisker_wheel_transitions');
%%
initial_vars = {};
initial_vars{end+1} = 'genotype';
initial_vars{end+1} = 'name';
initial_vars{end+1} = 'video_region_names';
initial_vars{end+1} = 'camera_regions';
initial_vars{end+1} = 'camera_wheel';
initial_vars{end+1} = 'camera_whisker';
initial_vars{end+1} = 'camera_fs';
initial_vars{end+1} = 'whisker_wheel_transitions';
%%
xylobium.dledit.Editor(trials,actions,initial_vars,mods);

end

