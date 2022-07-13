clear

%%
ts = get_tseries_unmerged(true);

%%
actions = xylobium.dledit.Action.empty();

actions(1) = xylobium.dledit.Action('Merge', ...
    @(trial,~,~) iris.processing_functions.merge_frames(trial, ...
    10, "TSeries", "h5","TSeries unmerged"), true, false);

actions(2) = xylobium.dledit.Action('Merge to unaligned', ...
    @(trial,~,~) iris.processing_functions.merge_frames(trial, ...
    10, "TSeries unaligned", "h5","TSeries unmerged"), true, false);

actions(3) = xylobium.dledit.Action('Merge to tiff', ...
    @(trial,~,~) iris.processing_functions.merge_frames(trial, ...
    10, "TSeries", "tif","TSeries tiff"), true, false);

vars = {};
vars{end+1} = 'path';

mods = xylobium.dledit.model.Modifier.empty;
mods(end+1) = iris.util.DisplayPathMod();

xylobium.dledit.Editor(ts,actions,vars, mods, true);
