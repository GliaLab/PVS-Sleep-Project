tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa_measurements(tm);
%%
heatmaps = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);
heatmaps.img_roa_frequency = [];

I = ismember(heatmaps.state,{'locomotion','whisking','quiet','nrem','is','rem'});
heatmaps = heatmaps(I,:);

I = heatmaps.genotype == 'wt_dual';
heatmaps = heatmaps(I,:);
%%
[L1,L2] = dogbane.table_processing.roa_heatmap.distance_all_to_all(heatmaps);

%
file_name = '~/Desktop/sleep_project/heatmap_overlap/L1_all2all_matrix.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writematrix(L1,file_name)

file_name = '~/Desktop/sleep_project/heatmap_overlap/L2_all2all_matrix.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writematrix(L2,file_name)
%%
tbl = heatmaps;
tbl.img_roa_density = [];
tbl.state_start = [];
tbl.state_end = [];
tbl.avg_img = [];
tbl.roa_ignore_mask = [];
file_name = '~/Desktop/sleep_project/heatmap_overlap/all2all_table.csv';
begonia.path.make_dirs(file_name);
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)