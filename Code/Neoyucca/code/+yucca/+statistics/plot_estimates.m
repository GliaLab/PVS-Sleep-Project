function plot_estimates(varargin)
p = inputParser;
p.addRequired('estimates');
p.addRequired('p_values');
p.addParameter('output_folder','');
p.addParameter('y_label','');
p.addParameter('plot_title','');
% Hack to allow 'p_values' be an optional positional input and still
% have parameter pairs work.
if nargin == 1
    varargin = [varargin(1),{table}];
end
if nargin > 1 && ~istable(varargin{2})
    varargin = [varargin(1),{table},varargin(2:end)];
end
p.parse(varargin{:});
begonia.util.dump_inputParser_vars_to_caller_workspace(p);
%%
set(0, 'DefaultTextInterpreter', 'none')
set(0, 'DefaultLegendInterpreter', 'none')

%% Save data
if ~isempty(output_folder)
    begonia.path.make_dirs(output_folder)

    file_name = fullfile(output_folder,'estimates.csv');
    if exist(file_name, 'file')==2
      delete(file_name);
    end
    writetable(estimates,file_name,'Delimiter',';')
    
    if ~isempty(p_values)
        file_name = fullfile(output_folder,'p_values.csv');
        if exist(file_name, 'file')==2
          delete(file_name);
        end
        writetable(p_values,file_name,'Delimiter',';')
    end
end

if ~ismember('predictor_2',estimates.Properties.VariableNames)
    %% Plot with one predictor.
    
    f = figure;
    f.Units = 'centimeter';
    f.Position(3:4) = [30,20];

    est = estimates.estimate;
    err = [estimates.estimate_lower,estimates.estimate_upper] - est;

    b = yucca.util.barwitherr(err,est);

    cats_1 = categories(estimates.predictor_1);

    if ~isempty(p_values)
        % Only use significant p values.
        I = p_values.p_value > 0.05;
        p_values(I,:) = [];
        % Plot p-values
        bar_index_1 = yucca.statistics.category2idx(p_values.comparison_1,cats_1);
        bar_index_2 = yucca.statistics.category2idx(p_values.comparison_2,cats_1);
        bar_index = [bar_index_1,bar_index_2];
        yucca.util.sigstar_best(bar_index,p_values.p_value);
    end

    % Label axes
    a = gca;
    a.XTick = 1:length(err);
    a.XTickLabel = cats_1;
    a.XTickLabelRotation = 45;
    a.FontSize = 14;
    a.Color = 'none';
    a.TickLabelInterpreter = 'none';

    ylabel(y_label)

    if ~isempty(plot_title)
        title(plot_title);
    end

    if ~isempty(output_folder)
        % Save
        file_name = fullfile(output_folder,'plot_1.png');
        export_fig(file_name);

        file_name = fullfile(output_folder,'plot_1.fig');
        export_fig(file_name);
    end
    
else
    %% Plot with two predictors #1
    f = figure;
    f.Units = 'centimeter';
    f.Position(3:4) = [30,20];

    % Get estimates in matrix and the categories.
    [est,cats_1,cats_2] = yucca.util.unstack(estimates.estimate,estimates.predictor_1,estimates.predictor_2);
    est_lower = yucca.util.unstack(estimates.estimate_lower,estimates.predictor_1,estimates.predictor_2);
    est_upper = yucca.util.unstack(estimates.estimate_upper,estimates.predictor_1,estimates.predictor_2);

    % Get the difference between the estimate and upper/lower to get the error.
    est_lower = est_lower - est;
    est_upper = est_upper - est;

    % Plot bars with error
    err = [];
    err(:,:,1) = est_lower;
    err(:,:,2) = est_upper;
    b = yucca.util.barwitherr(err,est);

    % Plot p-values
    if ~isempty(p_values)
        bar_index_1 = yucca.statistics.category2idx(p_values.comparison_1,cats_1,cats_2);
        bar_index_2 = yucca.statistics.category2idx(p_values.comparison_2,cats_1,cats_2);
        bar_index = cat(2,bar_index_1,bar_index_2);
        % Only pick out p_values that are in the same "group of bars".
        I = p_values.comparison_1(:,1) == p_values.comparison_2(:,1);
        % Only use significant p values.
        I = I & p_values.p_value <= 0.05;
        yucca.util.sigstar_best(bar_index(I,:),p_values.p_value(I));
    end

    cats_1 = cellstr(cats_1);
    cats_2 = cellstr(cats_2);

    % Label axes
    a = gca;
    a.XTickLabel = cats_1;
    a.FontSize = 14;
    a.Color = 'none';
    a.TickLabelInterpreter = 'none';

    l = legend(cats_2);

    ylabel(y_label)

    if ~isempty(plot_title)
        title(plot_title);
    end

    if ~isempty(output_folder)
        % Save
        file_name = fullfile(output_folder,'plot_1.png');
        export_fig(file_name);

        file_name = fullfile(output_folder,'plot_1.fig');
        export_fig(file_name);
    end
    %% Plot with two predictors #2
    f = figure;
    f.Units = 'centimeter';
    f.Position(3:4) = [30,20];

    % Get estimates in matrix and the categories.
    [est,cats_1,cats_2] = yucca.util.unstack(estimates.estimate,estimates.predictor_1,estimates.predictor_2);
    est_lower = yucca.util.unstack(estimates.estimate_lower,estimates.predictor_1,estimates.predictor_2);
    est_upper = yucca.util.unstack(estimates.estimate_upper,estimates.predictor_1,estimates.predictor_2);

    % Flip the groups of bars. 
    est = est';
    est_lower = est_lower';
    est_upper = est_upper';

    % Get the difference between the estimate and upper/lower to get the error.
    est_lower = est_lower - est;
    est_upper = est_upper - est;

    % Plot bars with error
    err = [];
    err(:,:,1) = est_lower;
    err(:,:,2) = est_upper;
    b = yucca.util.barwitherr(err,est);

    % Plot p-values, here the indices are "opposite" of the previous plot.
    if ~isempty(p_values)
        bar_index_1 = yucca.statistics.category2idx(p_values.comparison_1,cats_2,cats_1);
        bar_index_2 = yucca.statistics.category2idx(p_values.comparison_2,cats_2,cats_1);
        bar_index = cat(2,bar_index_1,bar_index_2);
        % Only pick out p_values that are in the same "group of bars".
        I = p_values.comparison_1(:,2) == p_values.comparison_2(:,2);
        % Only use significant p values.
        I = I & p_values.p_value <= 0.05;
        yucca.util.sigstar_best(bar_index(I,:),p_values.p_value(I));
    end

    cats_1 = cellstr(cats_1);
    cats_2 = cellstr(cats_2);

    % Label axes
    a = gca;
    a.XTickLabel = cats_2;
    a.FontSize = 14;
    a.Color = 'none';
    a.TickLabelInterpreter = 'none';

    l = legend(cats_1);

    ylabel(y_label)

    if ~isempty(plot_title)
        title(plot_title);
    end

    if ~isempty(output_folder)
        % Save
        file_name = fullfile(output_folder,'plot_2.png');
        export_fig(file_name);

        file_name = fullfile(output_folder,'plot_2.fig');
        export_fig(file_name);
    end
end
end

