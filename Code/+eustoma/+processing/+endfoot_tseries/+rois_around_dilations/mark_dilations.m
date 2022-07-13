clear all
close all force

ts = eustoma.get_endfoot_tseries();
ts = ts(ts.has_var('diameter'));
ts = ts(ts.has_var('recrig'));

trials = eustoma.get_endfoot_recrigs();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(ts);
%%

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark dilation', ...
    @(ts,~,~) run_it(ts), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = 'dilation_episodes';

xylobium.dledit.Editor(ts,actions,initial_vars,[],false); 
%%

function run_it(ts)

ep = "Dilation";
color = [0,0.5,0.5];
episode_choices = table(ep,color);

diameter = ts.load_var('diameter');

id = diameter(:,1);
y = diameter.diameter;
x = (0:length(y{1})-1) / diameter.vessel_fs(1);
x = repmat({x},height(diameter),1);

sleep_episodes = ts.find_dnode('recrig').load_var('sleep_episodes');
tbl = table;
tbl.ep = sleep_episodes.state;
tbl.ep_start = sleep_episodes.state_start;
tbl.ep_end = sleep_episodes.state_end;

yucca.processing.mark_episodes.MarkEpisodes(ts,'dilation_episodes',id,x,y,episode_choices,tbl);
end


