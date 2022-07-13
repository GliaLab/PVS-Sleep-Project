begonia.logging.set_level(1);

scans = eustoma.get_linescans(true);
scans = scans(scans.has_var('trial_id'));
%%
actions = xylobium.dledit.Action.empty();

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = '!vessel_type';
initial_vars{end+1} = '!vessel_id';
initial_vars{end+1} = '!note';

mod = eustoma.util.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);