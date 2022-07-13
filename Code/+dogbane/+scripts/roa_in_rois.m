tm.reset_filters();
tm.set_filter('has_roi_array','true');
tm.set_filter('ignored_roa_trial','false');
tm.print_filters();
%%
% dogbane.guis.roa_in_rois(tm);
%%
ts_info = dogbane.tables.other.ts_info(tm);
%% Gp ROA
roa_table_Gp = dogbane.tables.roa.roa_events(tm,'roa_table_Gp');
roa_table_Gp.roa_dur = roa_table_Gp.roa_t_end - roa_table_Gp.roa_t_start;
% Calulculate size/dur per trial.
[G,roa_per_trial_Gp] = findgroups(roa_table_Gp(:,{'genotype','mouse','trial','state'}));
roa_per_trial_Gp.roa_xy_size = splitapply(@mean,roa_table_Gp.roa_xy_size,G);
roa_per_trial_Gp.roa_dur = splitapply(@mean,roa_table_Gp.roa_dur,G);
% Add dx_squared info
roa_per_trial_Gp = innerjoin(roa_per_trial_Gp,ts_info);

%% AS ROA
roa_table_AS = dogbane.tables.roa.roa_events(tm,'roa_table_AS');
roa_table_AS.roa_dur = roa_table_AS.roa_t_end - roa_table_AS.roa_t_start;
% Calulculate size/dur per trial.
[G,roa_per_trial_AS] = findgroups(roa_table_AS(:,{'genotype','mouse','trial','state'}));
roa_per_trial_AS.roa_xy_size = splitapply(@mean,roa_table_AS.roa_xy_size,G);
roa_per_trial_AS.roa_dur = splitapply(@mean,roa_table_AS.roa_dur,G);
% Add dx_squared info
roa_per_trial_AS = innerjoin(roa_per_trial_AS,ts_info);
%%
roa_per_trial_AS.roi_group = categorical(repmat({'AS'},height(roa_per_trial_AS),1));
roa_per_trial_Gp.roi_group = categorical(repmat({'Gp'},height(roa_per_trial_Gp),1));
roa_per_trial_merged = cat(1,roa_per_trial_AS,roa_per_trial_Gp);
%% 
output_folder = '~/Desktop/sleep_project/Gp_vs_AS_roa_size_WT';
I = ismember(roa_per_trial_merged.genotype,{'wt_dual'});
tbl = roa_per_trial_merged(I,:);
[est,pval,mdl] = begonia.statistics.estimate(tbl, ...
    'roa_xy_size','roi_group','state', ...
    'log_transform',true, ...
    'count_groups',{'mouse','trial'}, ...
    'model_function',@(x)fitglme(x,'roa_xy_size ~ state * roi_group + (1 | dx_squared)'));

begonia.statistics.plot_estimates(est,pval,'output_folder',output_folder);
begonia.statistics.plot_residuals(mdl,output_folder);
%%
output_folder = '~/Desktop/sleep_project/Gp_vs_AS_roa_duration_WT';
I = ismember(roa_per_trial_merged.genotype,{'wt_dual'});
tbl = roa_per_trial_merged(I,:);
[est,pval,mdl] = begonia.statistics.estimate(tbl, ...
    'roa_dur','roi_group','state', ...
    'log_transform',true, ...
    'count_groups',{'mouse','trial'}, ...
    'model_function',@(x)fitglme(x,'roa_dur ~ state * roi_group + (1 | dx_squared)'));

begonia.statistics.plot_estimates(est,pval,'output_folder',output_folder);
begonia.statistics.plot_residuals(mdl,output_folder);
%% GP ROA size plot
output_folder = '~/Desktop/sleep_project/Gp_roa_size';
[est,pval,mdl] = begonia.statistics.estimate(roa_per_trial_Gp, ...
    'roa_xy_size','genotype','state', ...
    'log_transform',true, ...
    'count_groups',{'mouse','trial'}, ...
    'model_function',@(x)fitglme(x,'roa_xy_size ~ state * genotype + (1 | dx_squared)'));

begonia.statistics.plot_estimates(est,pval,'output_folder',output_folder);
begonia.statistics.plot_residuals(mdl,output_folder);
%% Gp ROA duration plot
output_folder = '~/Desktop/sleep_project/Gp_roa_duration';
[est,pval,mdl] = begonia.statistics.estimate(roa_per_trial_Gp, ...
    'roa_dur','genotype','state', ...
    'log_transform',true, ...
    'count_groups',{'mouse','trial'}, ...
    'model_function',@(x)fitglme(x,'roa_dur ~ state * genotype + (1 | dx_squared)'));

begonia.statistics.plot_estimates(est,pval,'output_folder',output_folder);
begonia.statistics.plot_residuals(mdl,output_folder);
%% GP ROA size plot
output_folder = '~/Desktop/sleep_project/AS_roa_size';
[est,pval,mdl] = begonia.statistics.estimate(roa_per_trial_AS, ...
    'roa_xy_size','genotype','state', ...
    'log_transform',true, ...
    'count_groups',{'mouse','trial'}, ...
    'model_function',@(x)fitglme(x,'roa_xy_size ~ state * genotype + (1 | dx_squared)'));

begonia.statistics.plot_estimates(est,pval,'output_folder',output_folder);
begonia.statistics.plot_residuals(mdl,output_folder);

%% AS ROA duration plot
output_folder = '~/Desktop/sleep_project/AS_roa_duration';
[est,pval,mdl] = begonia.statistics.estimate(roa_per_trial_AS, ...
    'roa_dur','genotype','state', ...
    'log_transform',true, ...
    'count_groups',{'mouse','trial'}, ...
    'model_function',@(x)fitglme(x,'roa_dur ~ state * genotype + (1 | dx_squared)'));

begonia.statistics.plot_estimates(est,pval,'output_folder',output_folder);
begonia.statistics.plot_residuals(mdl,output_folder);