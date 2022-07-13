tm.reset_filters();
%%
% dogbane.guis.camera(tm);
dogbane.guis.states(tm);

%%
tbl_micro = dogbane.tables.other.variable_to_table_rec_rig(tm,'microarousals');
%%
[G,genotype,mouse,experiment,trial] = findgroups(tbl_micro.genotype,...
    tbl_micro.mouse,tbl_micro.experiment,tbl_micro.trial);
N = splitapply(@(state)sum(state=='microarousal'),tbl_micro.state,G);
dur = splitapply(@(state,state_duration)sum(state_duration(state=='nrem')), ...
    tbl_micro.state,tbl_micro.state_duration,G);
freq = N ./ dur * 60 * 60;
tbl_micro_e = table(genotype,mouse,experiment,trial,N,dur,freq);
%%
begonia.util.scatterbox(tbl_micro_e.freq, ...
    tbl_micro_e.genotype, ...
    'overlay','sem')
ylabel('# microarousals / hour');
title('Microarousals per hour in NREM');
set(gca,'FontSize',20);
%%
dogbane.table_plots.states.microarousals_per_genotype(tbl_micro_e);
%%
output_folder = '~/Desktop/sleep_project/microarousals';

[estimates,p_values,model] = begonia.statistics.estimate(...
    tbl_micro_e, 'freq','genotype','', ...
    'log_transform',false, ...
    'count_groups',{'mouse','trial'});

begonia.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Microarousals per hour in NREM', ...
    'output_folder',output_folder);
begonia.statistics.plot_residuals(model,output_folder);

%%

grpstats(tbl_micro_e,{'genotype'},'sum','DataVars',{'N'})


