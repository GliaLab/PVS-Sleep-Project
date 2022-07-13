function mark_camera(trials_or_path)
if ischar(trials_or_path) || isstring(trials_or_path)
    trials = yucca.trial_search.find_trials(char(trials_or_path));
else
    trials = trials_or_path;
end

begonia.logging.set_level(1);

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark camera', ...
    @(trial,~,~) open_gui(trial), ...
    false, false);

actions(end+1) = xylobium.dledit.Action('Process camera', ...
    @(trial,~,~) yucca.processing.mark_camera.process_camera(trial), ...
    true, false);

initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = 'camera_rois';

xylobium.dledit.Editor(trials,actions,initial_vars,[],false);

end

function open_gui(trial)
camera_file = fullfile(trial.path,"camera.avi");
vr = VideoReader(camera_file);

yucca.processing.mark_camera.CameraMarker(vr,trial);

end
