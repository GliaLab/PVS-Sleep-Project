clear all
begonia.logging.set_level(1)

scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red'));
scans = scans(scans.has_var('recrig'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

% Sort by path.
path = scans.load_var('path');
[~,I] = sort(string(path),'descend');
scans = scans(I);

%% Only select trials with REM
I = false(length(scans));
for i = 1:length(scans)
  sleep_episodes = scans(i).find_dnode('recrig').load_var('sleep_episodes',[]);
  if ~isempty(sleep_episodes)
    if any(sleep_episodes.state == "REM")
      I(i) = true;
    end
  end
end
scans = scans(I);

%%

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark awakening', ...
    @(ts,~,~) run_it(ts), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'awakening_episodes';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);
%%

function run_it(scan)

ep = "Awakening";
color = [0,0.5,0.5];
episode_choices = table(ep,color);

diameter = scan.load_var('diameter_red');

id = diameter(:,1);
y = diameter.diameter;
x = (0:length(y{1})-1) / diameter.vessel_fs(1);
x = repmat({x},height(diameter),1);

sleep_episodes = scan.find_dnode('recrig').load_var('sleep_episodes',[]);
if isempty(sleep_episodes)
    tbl = [];
else
    tbl = table;
    tbl.ep = sleep_episodes.state;
    tbl.ep_start = sleep_episodes.state_start;
    tbl.ep_end = sleep_episodes.state_end;
end

yucca.processing.mark_episodes.MarkEpisodes(scan,'awakening_episodes',id,x,y,episode_choices,tbl);
end


