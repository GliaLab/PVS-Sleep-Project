clear

%%
ts = get_tseries(true);

%%
actions = xylobium.dledit.Action.empty();

actions(1) = xylobium.dledit.Action('Load trial_id', ...
    @(trial,~,~) iris.processing_functions.load_tseries_info(trial), ...
    true, false);

actions(2) = xylobium.dledit.Action('Calc avg. img.', ...
    @(trial,~,~) iris.processing_functions.calc_average_images(trial), ...
    true, false);

actions(3) = xylobium.dledit.Action('Calc fluo.', ...
    @(trial,~,~) iris.processing_functions.calc_channel_time_series(trial), ...
    true, false);

actions(4) = xylobium.dledit.Action('Plot img and traces', ...
    @(trial,~,~) iris.processing_functions.plot_image_and_channel_trace(trial), ...
    true, false);

vars = {};
vars{end+1} = 'path';
vars{end+1} = '?trial_id';
vars{end+1} = '?average_images';
vars{end+1} = '?channel_time_series';

mods = xylobium.dledit.model.Modifier.empty;
mods(end+1) = iris.util.DisplayPathMod();

xylobium.dledit.Editor(ts,actions,vars, mods, true);
