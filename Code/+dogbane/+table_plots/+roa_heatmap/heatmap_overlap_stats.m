function heatmap_overlap_stats(tbl,output_folder,num)

base_filename   = 'heatmap_overlap';
plot_title      = sprintf('Overlap of %d%% most active areas',num);
plot_y_label    = '% overlap';

response        = 'coeff';
predictor       = 'transition';
model_formula   = sprintf('%s ~ %s',response,predictor);

tbl.coeff = tbl.coeff * 100;

[estimates,p_vals,N,model] = dogbane.util.model_to_values_1_predictor( ...
    tbl, ...
    @(x)fitglme(x,model_formula), ...
    true, ...
    response, ...
    predictor);

%%
begonia.path.make_dirs(output_folder)
%% Save data
file_name = fullfile(output_folder,[base_filename,'_data.csv']);
if exist(file_name, 'file')==2
  delete(file_name);
end
writetable(tbl,file_name)

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
writetable(N,file_name)

%% Plot 1
f = figure;
f.Units = 'centimeter';
f.Position = [5,5,30,20];

err = [estimates.EstimateLower,estimates.EstimateUpper];
est = estimates.Estimate;

b = begonia.util.barwitherr(err,est);

% Only use significant p values.
I = p_vals.p_values > 0.05;
p_vals(I,:) = [];
% Plot p-values
grp1 = grp2idx(p_vals.combination_1);
grp2 = grp2idx(p_vals.combination_2);
groups = [grp1,grp2];
begonia.util.sigstar_best(groups,p_vals.p_values);

predictor_categories = cellstr(categories(tbl.(predictor)));

if strcmp(predictor,'state')
    predictor_categories = alyssum.constants.state_names_short2long(predictor_categories);
end

% Label axes
a = gca;
a.XTickLabel = predictor_categories;
a.FontSize = 14;
a.Color = 'none';
a.TickLabelInterpreter = 'none';

ylabel(plot_y_label)

title(plot_title,'Interpreter','none')

% Save
file_name = fullfile(output_folder,[base_filename,'.png']);
export_fig(file_name);

file_name = fullfile(output_folder,[base_filename,'.fig']);
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

