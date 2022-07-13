tm.reset_filters();
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
dogbane.guis.aqua(tm);
%%
tbl_aqua_per_trial = dogbane.tables.aqua.events_per_trial_and_state(tm);
%%
dogbane.table_plots.aqua.frequency_per_state(tbl_aqua_per_trial);
%% new way
[estimates,p_values,model] = begonia.statistics.estimate( ...
    tbl_aqua_per_trial, ...
    'freq', 'state', '', ...
    'log_transform', true, ...
    'model_function', @(x)fitglme(x,'freq ~ state  + (1 | dx_squared) + (-1 + state | mouse)'));

begonia.statistics.plot_estimates(estimates,p_values);
begonia.statistics.plot_residuals(model);
%%
begonia.statistics.grpstats(tbl_aqua_per_trial,{'genotype','mouse'},'freq')
%%
length(unique(tbl_aqua_per_trial.trial))