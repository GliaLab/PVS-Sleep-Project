tm.reset_filters();
tm.set_filter('has_roi_array','true');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%

%%
rois = dogbane.tables.roi.rois(tm);
ts_info = dogbane.tables.other.ts_info(tm);
rois = innerjoin(rois,ts_info);
rois.area = rois.area .* rois.dx_squared;
%%
[G,rois_per_grp] = findgroups(rois(:,{'genotype','roi_group'}));
rois_per_grp.mean_area = splitapply(@mean,rois.area,G);

rois_per_grp