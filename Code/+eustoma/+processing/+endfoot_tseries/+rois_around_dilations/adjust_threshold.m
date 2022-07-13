close all force
clear all
begonia.logging.set_level(1);
ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('vessel_table'));

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Find diameter', ...
    @(scan,~,~) fixit(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'vessel_table';
initial_vars{end+1} = 'vessel_threshold';
initial_vars{end+1} = '!vessel_threshold_note';

xylobium.dledit.Editor(ts,actions,initial_vars,[],false);

function fixit(ts)
vessels = ts.load_var('vessel_table');
yucca.processing.detect_linescan_diameter.DiameterDetector(ts, vessels, "vessel_threshold", "outer");
end