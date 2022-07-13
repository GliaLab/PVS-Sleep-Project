%%
tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('has_neuron_channel','true');
tm.set_filter('has_roi_array','true');
tm.set_filter('ignored_roa_trial','false');
tm.set_filter('has_rem','true');
tm.set_filter('has_nrem','true');
tm.set_filter('has_is','true');
tm.print_filters();

dogbane.guis.neu_ast_cor(tm);
%%
tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('has_neuron_channel','true');
tm.set_filter('has_roi_array','true');
tm.set_filter('ignored_roa_trial','false');
tm.set_filter('has_whisking','true');
tm.print_filters();

dogbane.guis.neu_ast_cor(tm);
%%
tm.reset_filters();
tm.set_filter('genotype','wt_dual');
tm.set_filter('has_neuron_channel','true');
tm.set_filter('has_roi_array','true');
tm.print_filters();

trials = tm.get_trials();
trial_ids = {trials.trial_id};
trial_ids = categorical(trial_ids);
%%
% quiet
dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
    trials(trial_ids == '20180225_NM16_trial_013'),[340,340+60]);
%%
% nrem
dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
    trials(trial_ids == '20180205_TL15_trial_012'),[390,390+60]);
%% 
% is
dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
    trials(trial_ids == '20180119_NM16_trial_013'),[145,145+60]);
%%
% rem
dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
    trials(trial_ids == '20180205_TL15_trial_012'),[110,110+60]);
%%
% locomotion
dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
    trials(trial_ids == '20180121_TL15_trial_019'),[60,120]);
%%
% whisking
% dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
%     trials(trial_ids == '20180225_NM16_trial_001'),[60,120]);
% dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
%     trials(trial_ids == '20180130_TR15_trial_005'),[20,20+60]);
dogbane.trial_processing.neu_ast_correlation.plot_roa_gp_vs_neu_gp( ...
    trials(trial_ids == '20180225_NM16_trial_009'),[10,10+60]);

