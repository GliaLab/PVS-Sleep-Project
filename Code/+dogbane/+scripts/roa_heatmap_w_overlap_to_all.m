tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa_measurements(tm);
%%
heatmaps = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);

I = heatmaps.genotype == 'wt_dual';
heatmaps = heatmaps(I,:);
%%
wjac = dogbane.table_processing.roa_heatmap.overlap_w_all_to_all(heatmaps);

%
file_name = '~/Desktop/sleep_project/heatmap_overlap/wjac_all2all_matrix.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writematrix(wjac,file_name)
%%
tbl = heatmaps;
tbl.total_activation = cellfun(@(x)mean(x(:)),tbl.img_roa_density);
tbl.img_roa_density = [];
tbl.img_roa_frequency = [];
tbl.state_start = [];
tbl.state_end = [];
tbl.avg_img = [];
tbl.roa_ignore_mask = [];
file_name = '~/Desktop/sleep_project/heatmap_overlap/wjac_all2all_table.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)
%% N

% Remove fovs that have less than 8 episodes
G = findgroups(tbl.fov_id);
ep_in_fov = splitapply(@length,tbl.fov_id,G);
fov_few_I = find(ep_in_fov < 8);
remove_ep_I = ismember(G,fov_few_I);

tbl_reduced = tbl;
tbl_reduced(remove_ep_I,:) = [];


tbl_N_all = table;
tbl_N_all.N_mice = length(unique(tbl_reduced.mouse));
tbl_N_all.N_fovs = length(unique(tbl_reduced.fov_id));
tbl_N_all.N_trials = length(unique(tbl_reduced.trial_id));
tbl_N_all.N_ep = height(tbl_reduced);
tbl_N_all.state = {'all'};

[G,tbl_N_state] = findgroups(tbl_reduced(:,{'state'}));
tbl_N_state.N_mice = splitapply(@(x)length(unique(x)),tbl_reduced.mouse,G);
tbl_N_state.N_fovs = splitapply(@(x)length(unique(x)),tbl_reduced.fov_id,G);
tbl_N_state.N_trials = splitapply(@(x)length(unique(x)),tbl_reduced.trial_id,G);
tbl_N_state.N_ep = splitapply(@length,tbl_reduced.fov_id,G);

tbl_N = cat(1,tbl_N_state,tbl_N_all)

file_name = '~/Desktop/sleep_project/heatmap_overlap/wjac_all2all_N.csv';

begonia.util.save_table(file_name,tbl_N);




