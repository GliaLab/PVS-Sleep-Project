tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('has_neuron_channel','true');
tm.set_filter('has_neuron_rois','true');
tm.set_filter('has_gp_traces','true');
tm.set_filter('has_roi_array','true');
tm.print_filters();
%%
% dogbane.guis.plots_with_NS(tm);
%%
trials = tm.get_trials;
trial_ids = {trials.trial_id};
ts = [trials.tseries];

fovs = ts.load_var('fov_id')';
fovs = cell2mat(fovs); 
%% Check which FOVs that also is used in the heatmap overlap calculation.
% The overlap table is generated in roa_heatmap_overlap_all_states.m
I = ismember(fovs,overlap.fov_id);
fovs_with_overlap = fovs(I)';

for i = find(I)'
    dogbane.trial_processing.plots_with_NS.plot_1(trials(i));
end