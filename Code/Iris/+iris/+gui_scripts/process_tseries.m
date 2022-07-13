clear

%%
ts = get_tseries(true);

%%
actions = xylobium.dledit.Action.empty();

actions(1) = xylobium.dledit.Action('Merge to tiff', ...
    @(trial,~,~) iris.processing_functions.merge_frames_to_tiff(trial), ...
    true, false);

actions(2) = xylobium.dledit.Action('Make mp4', ...
    @(trial,~,~) iris.processing_functions.Mp4Maker(trial), ...
    false, false);

vars = {};
vars{end+1} = 'path';

mods = xylobium.dledit.model.Modifier.empty;
mods(end+1) = iris.util.DisplayPathMod();

xylobium.dledit.Editor(ts,actions,vars, mods, true);
