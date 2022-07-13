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

overlap_per_mouse = begonia.statistics.grpstats(overlap,{'genotype','mouse','combination'},'coeff');
overlap_per_fov_id = begonia.statistics.grpstats(overlap,{'genotype','mouse','combination','fov_id'},'coeff');

%%
begonia.plot.scatterbox(overlap_per_fov_id.coeff * 100, ...
    overlap_per_fov_id.combination, ...
    overlap_per_fov_id.mouse, ...
    'overlay','sem')
set(gca,'FontSize',20)
%%
begonia.plot.scatterbox(overlap_per_mouse.coeff * 100, ...
    overlap_per_mouse.combination, ...
    overlap_per_mouse.mouse, ...
    'overlay','sem')
set(gca,'FontSize',20)
%%
[estimates,p_values,model] = begonia.statistics.est( ...
    overlap_per_fov_id.coeff * 100, overlap_per_fov_id.combination, ...
    'log_transform',true);

begonia.statistics.plot_estimates(estimates,p_values);
begonia.statistics.plot_residuals(model);
%%
output_folder = '~/Desktop/sleep_project/heatmap_overlap_same_states';
I = ismember(overlap_per_fov_id.combination,{'locomotion locomotion', ...
    'whisking whisking','quiet quiet','nrem nrem','is is','rem rem'});
tbl = overlap_per_fov_id(I,:);

[estimates,p_values,model] = begonia.statistics.est( ...
    tbl.coeff * 100, tbl.combination, ...
    'log_transform',true);

begonia.statistics.plot_estimates(estimates,p_values,'output_folder',output_folder);
begonia.statistics.plot_residuals(model,output_folder);
%%
output_folder = '~/Desktop/sleep_project/heatmap_overlap_different_states';
I = ~ismember(overlap_per_fov_id.combination,{'locomotion locomotion', ...
    'whisking whisking','quiet quiet','nrem nrem','is is','rem rem'});
tbl = overlap_per_fov_id(I,:);

[estimates,p_values,model] = begonia.statistics.est( ...
    tbl.coeff * 100, tbl.combination, ...
    'log_transform',true);

begonia.statistics.plot_estimates(estimates,p_values,'output_folder',output_folder);
begonia.statistics.plot_residuals(model,output_folder);
%% Make an overview of how many states each FOV has

I_l = overlap.combination == 'locomotion locomotion';
I_l = I_l & ismembertol(overlap.coeff,0.20,0.03);

I_w = overlap.combination == 'whisking whisking';
I_w = I_w & ismembertol(overlap.coeff,0.08,0.02);

I_q = overlap.combination == 'quiet quiet';
I_q = I_q & ismembertol(overlap.coeff,0.05,0.01);

I = I_l | I_w | I_q;
overlap_fov_comb = begonia.statistics.grpstats(overlap(I,:), ...
    {'genotype','mouse','fov_id'},'combination',@(x)length(unique(x)));
%%

tbl = overlap_fov_comb(overlap_fov_comb.combination == 3,:)

% for i = 1:height(tbl)
%     j = find(heatmaps.fov_id == tbl.fov_id(i),1,'first');
%     img = heatmaps.avg_img{j};
%     figure;
%     imshow(img);
%     set(gca,'CLim',[0,prctile(img(:),99)]);
%     
%     output_folder = '~/Desktop/sleep_project/heatmap_overlap_fovs_with_wake';
%     filename = sprintf('%s_fov_%d.png', ...
%         heatmaps.mouse(j), ...
%         heatmaps.fov_id(j));
%     filename = fullfile(output_folder,filename);
%     begonia.path.make_dirs(filename);
%     export_fig(filename,'-native')
%     close all
% end


%%
tbl = overlap_fov_comb(overlap_fov_comb.combination == 3,:)
for i = 1:height(tbl)
    output_folder = sprintf('~/Desktop/sleep_project/heatmap_overlap_wake_images_fov_%d',tbl.fov_id(i));
    I = overlap.fov_id == tbl.fov_id(i);
    I = I & (I_l | I_w | I_q);
    tbl1 = overlap(I,:);
    dogbane.table_plots.roa_heatmap.plot_overlapping_heatmap(tbl1,heatmaps,output_folder)
end