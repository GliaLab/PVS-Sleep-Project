
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('path'));
scans = scans(scans.has_var('vessels_green') | scans.has_var('vessels_red'));
scans = scans(scans.has_var('recrig'));

% trials = eustoma.get_linescans_recrig();
% 
% dloc_list = yucca.datanode.DataNodeList();
% dloc_list.add(trials);
% dloc_list.add(scans);

% I = scans.find_dnode('recrig').has_var("sleep_episodes");
% scans = scans(I);

%%
path = scans.load_var('path');
path = string(path);
[~,I] = sort(path,'descend');
scans = scans(I);

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Find green diameter', ...
    @(scan,~,~) fixitgreen(scan), ...
    false, false);

actions(end+1) = xylobium.dledit.Action('Find red diameter', ...
    @(scan,~,~) fixitred(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'trial_type';
initial_vars{end+1} = 'vessel_type';
initial_vars{end+1} = 'vessels_green_threshold';
initial_vars{end+1} = '!vessels_green_threshold_status';
initial_vars{end+1} = 'vessels_red_threshold';
initial_vars{end+1} = '!vessels_red_threshold_status';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);

%%

function fixitgreen(scan)
vessels = scan.load_var('vessels_green',[]);
if isempty(vessels)
    begonia.logging.log(1,"Green vessel data missing");
else
    eustoma.processing.linescans.diameter.DiameterDetector(scan, vessels, "vessels_green_threshold", "inner");
end
end

function fixitred(scan)
vessels = scan.load_var('vessels_red',[]);
if isempty(vessels)
    begonia.logging.log(1,"Green vessel data missing");
else
    eustoma.processing.linescans.diameter.DiameterDetector(scan, vessels, "vessels_red_threshold", "outer");
end
end