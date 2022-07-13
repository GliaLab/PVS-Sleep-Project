begonia.logging.set_level(1);

trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('sleep_episodes'));

scans = eustoma.get_linescans();

dloc_list = yucca.datanode.DataNodeList();
dloc_list.add(trials);
dloc_list.add(scans);
%%
tbl = begonia.data_management.var2table(trials,'sleep_episodes','path');
tbl.state_duration = tbl.state_end - tbl.state_start;

% Save all sleep episodes
path = fullfile(eustoma.get_plot_path, 'Linescan Sleep Data', ...
    'Sleep Episodes.csv');
begonia.util.save_table(path,tbl);
%% Save a table with the number of episodes and the connected linescan
[G,tbl_per_trial] = findgroups(tbl(:,{'path','state'}));
tbl_per_trial.num_episodes = splitapply(@length,tbl.state,G);

linescan_paths = begonia.data_management.var2table(trials,'linescan','path');
linescan_paths.linescan_path = cell(height(linescan_paths),1);
for i = 1:height(linescan_paths)
    scan = dloc_list.find_dnode(linescan_paths.linescan{i});
    linescan_paths.linescan_path{i} = scan.load_var('path');
end
linescan_paths.linescan = [];

tbl_per_trial = outerjoin(linescan_paths,tbl_per_trial,'MergeKeys',true, ...
    'Type','right');

path = fullfile(eustoma.get_plot_path, 'Linescan Sleep Data', ...
    'Sleep Episodes per Trial.csv');
begonia.util.save_table(path,tbl_per_trial);

%%

g = gramm('x',tbl.state_duration);
g.facet_grid(tbl.state,[],'scale','free_y');
g.stat_bin('edges',0:5:round(max(tbl.state_duration),-1));
g.set_names('x','Duration (s)','y','Number of episodes','row','', ...
    'column','', ...
    'color','Mouse');
g.set_title('Sleep Episode Duration Histogram (Bin width 5 seconds)');
g.axe_property('TickDir','out','YGrid','on','GridColor',[0.5 0.5 0.5]);
g.draw();
f = gcf;
f.Position(3:4) = [1600,700];

path = fullfile(eustoma.get_plot_path, 'Linescan Sleep Data', ...
    'Episode Histogram.png');
begonia.path.make_dirs(path);
pause(0.5);
warning off
saveas(f,path);
warning on
close(f)

