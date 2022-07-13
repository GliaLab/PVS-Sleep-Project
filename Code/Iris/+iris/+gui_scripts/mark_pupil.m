clear

%%
tr = get_labview_trials(true);

%%
actions = xylobium.dledit.Action.empty();

actions(1) = xylobium.dledit.Action('Crop pupil', ...
    @(trial,~,~) iris.processing_functions.CropPupil(trial), ...
    false, false);

actions(2) = xylobium.dledit.Action('Export pupil', ...
    @(trial,~,~) iris.processing_functions.export_pupil_video(trial), ...
    true, false);

actions(3) = xylobium.dledit.Action('Configure pupil', ...
    @(trial,~,~) iris.processing_functions.config_pupil(trial), ...
    false, false);

actions(4) = xylobium.dledit.Action('Calculate pupil', ...
    @(trial,~,~) iris.processing_functions.calc_pupil_mask(trial), ...
    true, false);

vars = {};
vars{end+1} = 'path';
vars{end+1} = '?pupil_crop';
vars{end+1} = 'pupil_threshold';
vars{end+1} = '?pupil_mask';

mods = xylobium.dledit.model.Modifier.empty;
mods(end+1) = iris.util.DisplayPathMod();

xylobium.dledit.Editor(tr,actions,vars, mods,false);