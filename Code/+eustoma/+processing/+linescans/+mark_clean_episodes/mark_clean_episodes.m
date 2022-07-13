begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('path'));
scans = scans(scans.has_var('diameter_red') & scans.has_var('diameter_green'));

%% Only awake trials
trial_type = scans.load_var('trial_type');
trial_type = string(trial_type);
scans = scans(trial_type == "Sleep");
%%
path = scans.load_var('path');
[~,I] = sort(string(path),'descend');
scans = scans(I);
%%

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark', ...
    @(scan,~,~) eustoma.processing.linescans.mark_clean_episodes.MarkEpisodes(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'trial_type';
initial_vars{end+1} = 'vessel_type';
initial_vars{end+1} = 'clean_episodes';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);
%%
