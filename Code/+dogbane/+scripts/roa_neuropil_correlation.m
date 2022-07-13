tm.reset_filters();
tm.set_filter('has_neuron_channel',true);
tm.set_filter('has_roi_array',true);
tm.set_filter('ignored_roa_trial',false);
%%
dogbane.guis.neu_ast_cor(tm);

%%
correlations = dogbane.tables.other.variable_to_table_tseries(tm,'correlate_gliopil_traces');
correlations.state = setcats(correlations.state,{'locomotion','whisking','quiet','nrem','is','rem'});
correlations.state_start = [];
correlations.state_end = [];
%%
corr_per_trial = begonia.statistics.grpstats(correlations,{'genotype','mouse','experiment','trial','state'});
corr_per_mouse = begonia.statistics.grpstats(correlations,{'genotype','mouse','state'});
%%
% close all
% output_folder = '~/Desktop/sleep_project/dogbane_2/frequency_of_episodes_in_sleep';

[estimates,p_values,model] = begonia.statistics.estimate( ...
    corr_per_trial,'roa_neu_corr','state','genotype', ...
    'model_function',@(x)fitglme(x,'roa_neu_corr ~ state*genotype + (-1 + state | mouse)'), ...
    'log_transform',false);

begonia.statistics.plot_estimates(estimates,p_values);
begonia.statistics.plot_residuals(model);

% begonia.statistics.plot_estimates(estimates,p_values, ...
%     'plot_title','Episodes per hour of total sleep', ...
%     'output_folder',output_folder);
% begonia.statistics.plot_residuals(model,output_folder);
%% Scatterbox per mouse. 
I = corr_per_mouse.genotype == 'wt_dual';
begonia.plot.scatterbox(corr_per_mouse(I,:).roa_neu_corr, ...
    corr_per_mouse(I,:).state, ...
    corr_per_mouse(I,:).mouse, ...
    'overlay','sem')
set(gca,'FontSize',20)
title('Correlation of ROA frequency in Gp vs. neuron df/f0 in Gp');
set(gcf,'Position',[400,400,1000,600])
filename = '~/Desktop/sleep_project/roa_neuron_correlations/corr_per_mouse.png';
begonia.path.make_dirs(filename)
export_fig(filename);

filename = '~/Desktop/sleep_project/roa_neuron_correlations/corr_per_mouse.xls';
begonia.path.make_dirs(filename)
if exist(filename, 'file')==2
  delete(filename);
end
writetable(corr_per_mouse(I,:),filename)
