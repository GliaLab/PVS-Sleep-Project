clear all

%% Load tseries
ts = get_tseries();
ts = ts(ts.has_var('vessel_diameter'));

%% GUI
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark dilations', ...
    @(x,~,~) fixit(x), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'vessel_dilations';

xylobium.dledit.Editor(ts,actions,initial_vars,[],false);
%%

function fixit(ts)
%%
vessel_diameter = ts.load_var("vessel_diameter");
episodes = ts.load_var("episodes");
iris.time_points.MarkTimePoints(ts,"vessel_dilations",vessel_diameter,"Vessel dilation",episodes);

end