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
I = randperm(height(heatmaps),500);

cnt = 0;
for i = I 
    cnt = cnt + 1;
    begonia.util.logging.backwrite(1,'%d/%d',cnt,length(I));
    path = '/Users/danielmb_adm/Desktop/sleep_project/dogbane/roa_density_heatmaps_per_ep/';
    filename = sprintf('%s fov %d %s %d.png', ...
        heatmaps.genotype(i), ...
        heatmaps.fov_id(i), ...
        heatmaps.state(i), ...
        i);
    path = fullfile(path,filename);
    
    f = figure;
    begonia.plot.imagesc_toiyt(heatmaps.img_roa_density{i});
    colorbar;
    begonia.path.make_dirs(path);
    export_fig(f,path,'-native');
    close(f);
end

begonia.util.logging.backwrite();
cnt = 0;
for i = I 
    cnt = cnt + 1;
    begonia.util.logging.backwrite(1,'%d/%d',cnt,length(I));
    path = '/Users/danielmb_adm/Desktop/sleep_project/dogbane/roa_frequency_heatmaps_per_ep/';
    filename = sprintf('%s fov %d %s %d.png', ...
        heatmaps.genotype(i), ...
        heatmaps.fov_id(i), ...
        heatmaps.state(i), ...
        i);
    path = fullfile(path,filename);
    
    f = figure;
    begonia.plot.imagesc_toiyt(heatmaps.img_roa_frequency{i});
    colorbar;
    begonia.path.make_dirs(path);
    export_fig(f,path,'-native');
    close(f);
end


