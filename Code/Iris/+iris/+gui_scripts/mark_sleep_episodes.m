clear

%%
tr = get_labview_trials(true);

%%
actions = xylobium.dledit.Action.empty();

actions(1) = xylobium.dledit.Action('Load ephys', ...
    @(trial,~,~) iris.processing_functions.load_ephys(trial), ...
    true, false);

actions(2) = xylobium.dledit.Action('Calc theta ratio', ...
    @(trial,~,~) iris.processing_functions.calc_sleep_metrics(trial), ...
    true, false);

actions(3) = xylobium.dledit.Action('Mark Sleep', ...
    @(trial,~,~) iris.processing_functions.mark_sleep_episodes(trial), ...
    false, false);

vars = {};
vars{end+1} = 'path';
vars{end+1} = '?ecog';
vars{end+1} = '?theta_ratio';
vars{end+1} = '?sleep_episodes';

mods = xylobium.dledit.model.Modifier.empty;
mods(end+1) = iris.util.DisplayPathMod();

xylobium.dledit.Editor(tr,actions,vars, mods,false);