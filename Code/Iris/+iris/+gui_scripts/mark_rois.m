
%%
ts = get_tseries(true);

% Sort ts by path.
paths = string({ts.path});
[~,I] = sort(paths);
ts = ts(I);

%% Open ROImanager
close all force

import xylobium.dledit.Action;
import dataman.actions.roi.*;
import xylobium.dledit.mods.HasVarMod;

ac_refs = Action("Gener. ref. images", @make_reference_images, false, true, "o");
ac_refs.menu_position = "RoIs";
ac_refs.accept_multiple_dlocs = false;
ac_refs.can_queue = true;
ac_refs.can_execute_without_dloc = false;
ac_refs.has_button = true;
ac_refs.button_group = "Regions-of-interest";

ac_mark = Action("Mark RoIs", @mark_rois, false, true, "m");
ac_mark.menu_position = "RoIs";
ac_mark.accept_multiple_dlocs = false;
ac_mark.can_queue = false;
ac_mark.can_execute_without_dloc = false;
ac_mark.has_button = true;
ac_mark.button_group = "Regions-of-interest";

actions= [ac_refs, ac_mark];

vars = {};
vars{end+1} = 'trial_id';
vars{end+1} = 'roi_table';

mods = xylobium.dledit.model.Modifier.empty;

mods(end+1) = HasVarMod("roi_table");

editor = dataman.Dataman(ts, actions, vars, mods);