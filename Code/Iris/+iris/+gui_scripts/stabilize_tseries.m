clear

%%
ts = get_tseries_unaligned(true);

%%
actions = xylobium.dledit.Action.empty();

actions(1) = xylobium.dledit.Action('NoRMCorre ch1', ...
    @(trial,~,~) iris.processing_functions.stabilize_with_normcorre(trial, 1, trial.load_var("stabilization_output_dir",[])), ...
    true, false);

actions(2) = xylobium.dledit.Action('NoRMCorre ch2', ...
    @(trial,~,~) iris.processing_functions.stabilize_with_normcorre(trial, 2, trial.load_var("stabilization_output_dir",[])), ...
    true, false);

vars = {};
vars{end+1} = 'path';
vars{end+1} = '!stabilization_output_dir';
vars{end+1} = 'stabilized';

mods = xylobium.dledit.model.Modifier.empty;
mods(end+1) = iris.util.DisplayPathMod();
mods(end+1) = iris.util.IsStabilizedMod();

xylobium.dledit.Editor(ts,actions,vars, mods, true);
