begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red'));
scans = scans(scans.has_var('recrig'));

trials = eustoma.get_linescans_recrig();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);

linescan_info = scans.load_var('linescan_info');
linescan_info = [linescan_info{:}];
start_times = [linescan_info.start_time];
[~,I] = sort(start_times,'descend');
scans = scans(I);

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark Baseline', ...
    @(scan,~,~) eustoma.processing.linescans.baseline_episodes.EpisodeMarker(scan), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = 'baseline_episodes';

xylobium.dledit.Editor(scans,actions,initial_vars,[],false);