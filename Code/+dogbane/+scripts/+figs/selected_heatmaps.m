begonia.util.imagesc_toiyt(tbl_roa_heatmaps_per_ep.avg_img{501})
colormap(gray)
set(gca,'CLim',[0,1000]);
export_fig('fov_93.png','-native');

begonia.util.imagesc_toiyt(tbl_roa_heatmaps_per_ep.avg_img{1953})
colormap(gray)
set(gca,'CLim',[0,2000]);
export_fig('fov_228.png','-native');

begonia.util.imagesc_toiyt(tbl_roa_heatmaps_per_ep.avg_img{2252})
colormap(gray)
set(gca,'CLim',[0,2000]);
export_fig('fov_299.png','-native');