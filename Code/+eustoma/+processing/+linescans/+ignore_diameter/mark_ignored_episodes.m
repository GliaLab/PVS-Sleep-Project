begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('path'));
scans = scans(scans.has_var('diameter_red') | scans.has_var('diameter_green'));

%% Only awake trials
trial_type = scans.load_var('trial_type');
trial_type = string(trial_type);
scans = scans(trial_type == "Awake");
%%
path = scans.load_var('path');
[~,I] = sort(string(path),'descend');
scans = scans(I);
%%

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Ignore episodes red', ...
    @(scan,~,~) fix_red(scan), ...
    false, false);

actions(end+1) = xylobium.dledit.Action('Ignore episodes green', ...
    @(scan,~,~) fix_green(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = '?diameter_red';
initial_vars{end+1} = 'ignored_episodes_red';
initial_vars{end+1} = '?diameter_green';
initial_vars{end+1} = 'ignored_episodes_green';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);

%%

function fix_red(scan)
if scan.has_var("diameter_red")
    eustoma.processing.linescans.ignore_diameter.IgnoreEpisodes(scan, "diameter_red", "ignored_episodes_red");
end
end

function fix_green(scan)
if scan.has_var("diameter_green")
    eustoma.processing.linescans.ignore_diameter.IgnoreEpisodes(scan, "diameter_green", "ignored_episodes_green");
end
end