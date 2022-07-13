clear all
close all force

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var("trial_id"));
ts = ts(ts.has_var("vessel_linescan"));

%%
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Find diameter', ...
    @(scan,~,~) fixit(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'vessel_diameter_threshold';

xylobium.dledit.Editor(ts,actions,initial_vars,[],false);

function fixit(ts)
vessel_linescan = ts.load_var('vessel_linescan');
iris.linescan.DiameterDetector(ts, vessel_linescan, "vessel_diameter_threshold", "inner");
end
