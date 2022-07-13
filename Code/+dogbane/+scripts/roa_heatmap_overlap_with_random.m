tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa_measurements(tm);
%%
heatmaps = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);

I = ismember(heatmaps.state,{'locomotion','whisking','quiet','nrem','is','rem'});
heatmaps = heatmaps(I,:);

I = heatmaps.genotype == 'wt_dual';
heatmaps = heatmaps(I,:);
%%
overlap = dogbane.table_processing.roa_heatmap.overlap_all_episodes(heatmaps);
%% N
I = ismember(heatmaps.fov_id,overlap.fov_id);
[G,tbl] = findgroups(heatmaps(I,{'genotype'}));
tbl.N_mice = splitapply(@(x)length(unique(x)),heatmaps.mouse(I),G);
tbl.N_trials = splitapply(@(x)length(unique(x)),heatmaps.trial_id(I),G);
tbl.N_uniqe_fovs = splitapply(@(x)length(unique(x)),heatmaps.fov_id(I),G);
tbl

% [G,tbl] = findgroups(overlap(:,{'genotype'}));
% tbl.N_mice = splitapply(@(x)length(unique(x)),overlap.mouse,G);
% tbl.N_uniqe_fovs = splitapply(@(x)length(unique(x)),overlap.fov_id,G);
% tbl

[G,tbl] = findgroups(overlap(:,{'genotype','combination'}));
tbl.N_mice = splitapply(@(x)length(unique(x)),overlap.mouse,G);
tbl.N_uniqe_fovs = splitapply(@(x)length(unique(x)),overlap.fov_id,G);
tbl.N_episode_comparisons = splitapply(@(x)length(x),overlap.coeff,G);
tbl

%%
overlap = dogbane.table_processing.roa_heatmap.overlap_random(overlap,heatmaps,1000);
%%
file_name = '~/Desktop/sleep_project/heatmap_overlap/overlap.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(overlap,file_name)