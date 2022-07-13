tm.reset_filters();
tm.set_filter('has_neuron_channel','true');
tm.set_filter('has_roi_array','true');
tm.print_filters();
%%
dogbane.guis.roi(tm);
%%
roi_events = dogbane.tables.other.variable_to_table_tseries(tm,'roi_events');
rois = dogbane.tables.roi.rois(tm);
rois = dogbane.table_processing.roi.events_per_roi(rois,roi_events);
%% Find ratio of silent ROIs

[G,num_rois] = findgroups(rois(:,{'genotype','roi_group'}));
num_rois.silent_rois = splitapply(@(x)sum(x == 0),rois.num_events,G);
num_rois.rois = splitapply(@length,rois.num_events,G);
num_rois.silent_ratio = num_rois.silent_rois ./ num_rois.rois;
num_rois