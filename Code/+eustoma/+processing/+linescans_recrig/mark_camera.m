
trials = eustoma.get_linescans_recrig(true);
trials = trials(trials.has_var('trial_id'));
%%
trials = trials(trials.has_var('trial_type'));
trial_type = string(trials.load_var('trial_type'));
trials = trials(trial_type == "Awake");
%%
trial_id = trials.load_var('trial_id');
trial_id = [trial_id{:}];
trial_id = [trial_id.trial_id];
[~,I] = sort(trial_id,'descend');
trials = trials(I);
%%

begonia.logging.set_level(1);

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark camera', ...
    @(trial,~,~) open_gui(trial), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'trial_type';
initial_vars{end+1} = 'camera_rois';
initial_vars{end+1} = 'camera_status';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(trials,actions,initial_vars,mod,false);
%%

function open_gui(trial)
camera_file = fullfile(trial.path,"camera.avi");
vr = VideoReader(camera_file);

yucca.processing.mark_camera.CameraMarker(vr,trial);

end
