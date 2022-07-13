begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('path'));
scans = scans(scans.has_var('diameter_red') & scans.has_var('diameter_green'));

% Only select trials with NREM.
I = false(length(scans),1);
for i = 1:length(scans)
    episodes = scans(i).load_var('episodes');
    I(i) = any(episodes.state == "NREM");
end
scans = scans(I);

% Sort by path.
path = scans.load_var('path');
[~,I] = sort(string(path),'descend');
scans = scans(I);

% GUI
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark dilations', ...
    @(scan,~,~) eustoma.processing.linescans.mark_dilation.MarkDilations(scan), ...
    false, false);

actions(end+1) = xylobium.dledit.Action('Mark pvs', ...
    @(scan,~,~) eustoma.processing.linescans.mark_dilation.MarkPVS(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'trial_type';
initial_vars{end+1} = 'vessel_type';
initial_vars{end+1} = 'dilation_timepoints';
initial_vars{end+1} = 'pvs_timepoints';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);
%%
