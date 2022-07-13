
rr = eustoma.get_endfoot_recrigs();

vesdist = begonia.data_management.var2table(rr,'vesdist_per_ep');
vesdist.state = reordercats(vesdist.state,{'Locomotion','Whisking','Quiet','NREM','IS','REM'});
vesdist = sortrows(vesdist,'state');

begonia.logging.set_level(1);
warning off
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Perivascular Artery');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Artery',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.diff_peri,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.diff_peri,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_peri,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'diff_peri','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'diff_peri ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Diamater change (um)', ...
    'plot_title','Artery Perivascular Width Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Endfoot Artery');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Artery',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.diff_endfoot,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.diff_endfoot,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_endfoot,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'diff_endfoot','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'diff_endfoot ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Diamater change (um)', ...
    'plot_title','Endfoot Artery Diameter Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Lumen Artery');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Artery',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.diff_lumen,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.diff_lumen,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_lumen,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'diff_lumen','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'diff_lumen ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Diamater change (um)', ...
    'plot_title','Lumen Artery Diameter Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Perivascular Vein');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Vein',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.diff_peri,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.diff_peri,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_peri,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'diff_peri','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'diff_peri ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Diamater change (um)', ...
    'plot_title','Vein Perivascular Width Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Endfoot Vein');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Vein',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.diff_endfoot,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.diff_endfoot,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_endfoot,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'diff_endfoot','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'diff_endfoot ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Diamater change (um)', ...
    'plot_title','Endfoot Vein Diameter Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Lumen Vein');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Vein',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.diff_lumen,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.diff_lumen,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_lumen,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'diff_lumen','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'diff_lumen ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Diamater change (um)', ...
    'plot_title','Lumen Vein Diameter Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Perivascular Vein Area');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Vein',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.area_diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.area_diff_peri,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.area_diff_peri,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_peri,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'area_diff_peri','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'area_diff_peri ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Area Change (um^2)', ...
    'plot_title','Perivascular Vein Area Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
plot_dir = fullfile(eustoma.get_plot_path,'Endfeet Vesdist Change Bar', ...
    'Perivascular Artery Area');

tbl = vesdist;
tbl = tbl(tbl.vessel_type == 'Artery',:);
tbl(tbl.state == 'Quiet',:) = [];

[G,tbl_bad] = findgroups(tbl(:,{'mouse'}));
tbl_bad.N = splitapply(@length,tbl.area_diff_peri,G);
tbl_bad.N_inf = splitapply(@(x)sum(isinf(x)),tbl.area_diff_peri,G);
tbl_bad.N_nan = splitapply(@(x)sum(isnan(x)),tbl.area_diff_peri,G);
tbl_bad.N_negative_baseline = splitapply(@(x)sum(x < 0),tbl.baseline_peri,G);
path = fullfile(plot_dir,'Bad Samples.csv');
begonia.util.save_table(path,tbl_bad);

I = isinf(tbl.diff_peri) | isnan(tbl.diff_peri);
tbl(I,:) = [];

tbl(tbl.mouse == 'M1',:) = [];

[estimates,p_values,model,r_ef] = yucca.statistics.estimate_with_random(...
    tbl, 'area_diff_peri','state','', ...
    'log_transform', false, ...
    'model_function', @(x)fitlme(x,'area_diff_peri ~ state + (state | mouse)'),...
    'count_groups',{'mouse','trial','vessel_id'});

yucca.statistics.plot_estimates(estimates,p_values, ...
    'y_label','Area Change (um^2)', ...
    'plot_title','Perivascular Artery Area Change from Baseline', ...
    'output_folder',plot_dir);
yucca.statistics.plot_residuals(model,plot_dir);

tmp = table;
tmp.N_mice = length(unique(tbl.mouse));
tmp.N_trials = length(unique(tbl.trial));
tmp.N_vessels = length(unique(tbl.vessel_id));

begonia.util.save_table(fullfile(plot_dir,'N.csv'),tmp);
close all

% Save random effects
f = figure;
f.Position(3:4) = [1000,700];
yucca.plot.scatterbox( ...
    r_ef.estimate, ...
    r_ef.name, ...
    r_ef.level);
title('Random effects');
path = fullfile(plot_dir,'random_effects.png');
begonia.path.make_dirs(path);
export_fig(path);
path = fullfile(plot_dir,'random_effects.csv');
begonia.util.save_table(path,r_ef);
close all
%%
warning on