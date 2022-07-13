function roa_frequency_in_endfeet_per_genotype(tbl_roa_in_endfeet,genotype)
output_folder = '~/Desktop/bar_plots/roa_frequency_in_endfeet_per_genotype';

base_filename   = sprintf('roa_freq_%s',genotype);
plot_title      = sprintf('ROA frequency in %s',genotype);
plot_y_label    = 'ROA Events / min / 100um2';
response        = 'roa_freq';
predictor_1     = 'roi_group';
predictor_2     = 'state';
model_formula   = sprintf('%s ~ %s*%s + (1 | dx_squared) + (-1 + state | mouse)',response,predictor_1,predictor_2);

tbl_roa_in_endfeet.roa_freq = tbl_roa_in_endfeet.roa_freq * 60 * 100;

tbl_roa_in_endfeet.genotype = setcats(tbl_roa_in_endfeet.genotype,{genotype});
tbl_roa_in_endfeet(isundefined(tbl_roa_in_endfeet.genotype),:) = [];

tbl_roa_in_endfeet.state = setcats(tbl_roa_in_endfeet.state,{'locomotion','whisking','quiet','nrem','is','rem'});
tbl_roa_in_endfeet(isundefined(tbl_roa_in_endfeet.state),:) = [];

tbl_roa_in_endfeet.roi_group = setcats(tbl_roa_in_endfeet.roi_group,{'Ar','Ve','Ca'});
tbl_roa_in_endfeet(isundefined(tbl_roa_in_endfeet.roi_group),:) = [];

[estimates,p_vals,N,model] = dogbane.util.model_to_values( ...
    tbl_roa_in_endfeet, ...
    @(x)fitglme(x,model_formula), ...
    true, ...
    response, ...
    predictor_1, ...
    predictor_2);
%%
begonia.path.make_dirs(output_folder)
%% Save data
file_name = fullfile(output_folder,[base_filename,'_estimates.xls']);
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(estimates,file_name)

file_name = fullfile(output_folder,[base_filename,'_p_values.xls']);
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(p_vals,file_name)

file_name = fullfile(output_folder,[base_filename,'_samples.xls']);
if exist(file_name, 'file')==2
  delete(file_name);
end
N.group = N.Properties.RowNames;
writetable(N,file_name)

%% Plot 1
f = figure;
f.Units = 'centimeter';
f.Position = [5,5,30,20];

% Get estimates in matrix and the categories.
[est,vars_1,vars_2] = begonia.util.unstack(estimates.Estimate,estimates.(predictor_1),estimates.(predictor_2));
est_lower = begonia.util.unstack(estimates.EstimateLower,estimates.(predictor_1),estimates.(predictor_2));
est_upper = begonia.util.unstack(estimates.EstimateUpper,estimates.(predictor_1),estimates.(predictor_2));
err = [];

% Plot bars with error
err(:,:,1) = est_lower;
err(:,:,2) = est_upper;
b = begonia.util.barwitherr(err,est);

% Plot p-values
group_1 = alyssum.util.combination2group(p_vals.combination_1,vars_1,vars_2);
group_2 = alyssum.util.combination2group(p_vals.combination_2,vars_1,vars_2);
groups = cat(2,group_1,group_2);
% Only pick out p_values within the same state
I = p_vals.combination_1(:,2) == p_vals.combination_2(:,2);
% Only use significant p values.
I = I & p_vals.p_values <= 0.05;
begonia.util.sigstar_best(groups(I,:),p_vals.p_values(I));

vars_1 = cellstr(vars_1);
vars_2 = cellstr(vars_2);

if strcmp(predictor_1,'state')
    vars_1 = alyssum.constants.state_names_short2long(vars_1);
end

if strcmp(predictor_2,'state')
    for i = 1:length(vars_2)
        b(i).FaceColor = alyssum.constants.state_names_short2colors(vars_2(i));
    end
    
    vars_2 = alyssum.constants.state_names_short2long(vars_2);
end

% Label axes
a = gca;
a.XTickLabel = vars_1;
a.FontSize = 14;
a.Color = 'none';
a.TickLabelInterpreter = 'none';

l = legend(vars_2);
l.Interpreter = 'none';

ylabel(plot_y_label)

title(plot_title,'Interpreter','none')

% Save
file_name = fullfile(output_folder,[base_filename,'_1.png']);
export_fig(file_name);

file_name = fullfile(output_folder,[base_filename,'_1.fig']);
export_fig(file_name);

%% Plot 2
f = figure;
f.Units = 'centimeter';
f.Position = [5,5,30,20];

% Get estimates in matrix and the categories.
[est,vars_2,vars_1] = begonia.util.unstack(estimates.Estimate,estimates.(predictor_2),estimates.(predictor_1));
est_lower = begonia.util.unstack(estimates.EstimateLower,estimates.(predictor_2),estimates.(predictor_1));
est_upper = begonia.util.unstack(estimates.EstimateUpper,estimates.(predictor_2),estimates.(predictor_1));
err = [];

% Plot bars with error
err(:,:,1) = est_lower;
err(:,:,2) = est_upper;
b = begonia.util.barwitherr(err,est);

% Plot p-values
group_1 = alyssum.util.combination2group(p_vals.combination_1,vars_2,vars_1);
group_2 = alyssum.util.combination2group(p_vals.combination_2,vars_2,vars_1);
groups = cat(2,group_1,group_2);
% Only pick out p_values within the same state
I = p_vals.combination_1(:,1) == p_vals.combination_2(:,1);
% Only use significant p values.
I = I & p_vals.p_values <= 0.05;
begonia.util.sigstar_best(groups(I,:),p_vals.p_values(I));

vars_1 = cellstr(vars_1);
vars_2 = cellstr(vars_2);

if strcmp(predictor_2,'state')
    vars_2 = alyssum.constants.state_names_short2long(vars_2);
end

if strcmp(predictor_1,'state')
    for i = 1:length(vars_1)
        b(i).FaceColor = alyssum.constants.state_names_short2colors(vars_1(i));
    end
    
    vars_1 = alyssum.constants.state_names_short2long(vars_1);
end

% Label axes
a = gca;
a.XTickLabel = vars_2;
a.FontSize = 14;
a.Color = 'none';
a.TickLabelInterpreter = 'none';

l = legend(vars_1);
l.Interpreter = 'none';

ylabel(plot_y_label)

title(plot_title,'Interpreter','none')

% Save
file_name = fullfile(output_folder,[base_filename,'_2.png']);
export_fig(file_name);

file_name = fullfile(output_folder,[base_filename,'_2.fig']);
export_fig(file_name);

%% residuals
figure;
model.plotResiduals('histogram');
% Save
file_name = fullfile(output_folder,[base_filename,'_res_hist.png']);
export_fig(file_name);
file_name = fullfile(output_folder,[base_filename,'_res_hist.fig']);
export_fig(file_name);

figure;
model.plotResiduals('probability');
% Save
file_name = fullfile(output_folder,[base_filename,'_res_prob.png']);
export_fig(file_name);
file_name = fullfile(output_folder,[base_filename,'_res_prob.fig']);
end

