begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('vessels_red_raw'));
scans = scans(scans.has_var('vessels_green_raw'));

path = scans.load_var('path');
path = string(path);
[~,I] = sort(path,'descend');
scans = scans(I);

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Adjust crosstalk', ...
    @(scan,~,~) fixit(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'crosstalk_factor';

mod = xylobium.dledit.mods.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(scans,actions,initial_vars,mod,false);

%%

function fixit(scan)

vessels_green = scan.load_var('vessels_green_raw');
vessels_red = scan.load_var('vessels_red_raw');

img1 = vessels_red.vessel{end};
img2 = vessels_green.vessel{end};

eustoma.processing.linescans.crosstalk.CrosstalkGUI(scan,img1,img2);

end