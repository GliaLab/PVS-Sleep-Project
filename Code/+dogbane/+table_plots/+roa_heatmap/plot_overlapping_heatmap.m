function plot_overlapping_heatmap(tbl_overlap,tbl_heatmaps,output_folder)

for n = 1:height(tbl_overlap)
    i = tbl_overlap.ep_idx(n,1);
    j = tbl_overlap.ep_idx(n,2);

    img_i = tbl_heatmaps.img_roa_frequency{i} > 0;
    img_j = tbl_heatmaps.img_roa_frequency{j} > 0;
    img_background = tbl_heatmaps.avg_img{i};

    f = figure;
    dogbane.plots.overlap_on_background(img_background,img_i,img_j);

    if ~isempty(output_folder)
        filename = sprintf('%s_fov_%d_%s_%s_overlap_%06.2f%%.png', ...
            tbl_overlap.mouse(n), ...
            tbl_overlap.fov_id(n), ...
            tbl_overlap.state_1(n), ...
            tbl_overlap.state_2(n), ...
            tbl_overlap.coeff(n)*100);
        filename = fullfile(output_folder,filename);
        
        begonia.path.make_dirs(filename);
        export_fig(filename,'-native')
    
        close(f);
    end
end

end

