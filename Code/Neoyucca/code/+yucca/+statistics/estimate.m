function [estimates,p_values,model] = estimate(varargin)
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('tbl');
p.addRequired('response');
p.addRequired('predictor_1');
p.addRequired('predictor_2');
p.addParameter('log_transform',false);
p.addParameter('model_function',[]);
p.addParameter('link_function',[]);
p.addParameter('count_groups',{});
p.parse(varargin{:});
begonia.util.dump_inputParser_vars_to_caller_workspace(p);
%%
tbl = yucca.util.removecats_table(tbl);
%%
if isempty(model_function)
    if isempty(predictor_2)
        model_formula = sprintf('%s ~ %s',response,predictor_1);
    else
        model_formula = sprintf('%s ~ %s * %s',response,predictor_1,predictor_2);
    end
    model_function = @(x)fitlm(x,model_formula);

    if log_transform
        I = tbl.(response) == 0;
        begonia.logging.log(1,'Ignoring %d  zero-samples (%g%%)',sum(I),100*sum(I)/height(tbl));
        tbl(I,:) = [];
        tbl.(response) = log(tbl.(response));
        link_function = @(x) exp(x);
    else
        link_function = @(x) x;
    end
else
    if log_transform
        I = tbl.(response) == 0;
        begonia.logging.log(1,'Ignoring %d  zero-samples (%g%%)',sum(I),100*sum(I)/height(tbl));
        tbl(I,:) = [];
        tbl.(response) = log(tbl.(response));
        % If there is no link function supplied, use the exp transform. If
        % there is a link function, modify it to accomadate the log
        % transformed data.
        if isempty(link_function)
            link_function = @(x) exp(x);
        else
            warning('Log transformed data with external link function has not been tested.');
            link_function = @(x) exp(link_function(x));
        end
    else
        if isempty(link_function)
            link_function = @(x) x;
        end
    end
end

%% Run model and change the intercepts to find p-values. 
p_values = table;

% Return the first model run.
model = model_function(tbl);

if isempty(predictor_2)
    %% Output only one predictor.
    categories_1 = categories(tbl.(predictor_1));

    N = length(categories_1);

    estimates = table;
    estimates.predictor_1 = categorical(repmat({''},N,1));
    for i = 1:length(count_groups)
        estimates.(['N_',count_groups{i}]) = nan(N,1);
    end
    estimates.N = zeros(N,1);
    estimates.estimate = nan(N,1);
    estimates.estimate_upper = nan(N,1);
    estimates.estimate_lower = nan(N,1);
    estimates.p_from_0 = nan(N,1);

    cnt = 1;
    begonia.logging.backwrite();
    for i = 1:length(categories_1)
        %% Run the model.
        begonia.logging.backwrite(1,'shifting (%d/%d)',cnt,N);

        % The intercept is the first category of the predictors.
        estimates.predictor_1(cnt) = categories_1(1);
        for k = 1:length(count_groups)
            I = tbl.(predictor_1) == categories_1(1);
            estimates.(['N_',count_groups{k}])(cnt) = ...
                length(unique(tbl.(count_groups{k})(I)));
        end
        estimates.N(cnt) = sum(tbl.(predictor_1) == categories_1(1));

        % Run the model.
        mdl = model_function(tbl);

        % The intercept is the first category of the predictors.
        estimates.predictor_1(cnt) = categories_1(1);
        estimates.estimate(cnt) = link_function(mdl.Coefficients.Estimate(1));
        estimates.estimate_upper(cnt) = ...
            link_function(mdl.Coefficients.Estimate(1) + mdl.Coefficients.SE(1));
        estimates.estimate_lower(cnt) = ...
            link_function(mdl.Coefficients.Estimate(1) - mdl.Coefficients.SE(1));
        estimates.p_from_0(cnt) = mdl.Coefficients.pValue(1);

        %% Find p-values
        comparison_1 = categorical;
        comparison_2 = categorical;
        p_value = nan(0,1);

        p_cnt = 1;

        % Look for matches to categories_1
        % Skipping the intercept by starting at n=2.
        for n = 2:length(categories_1)
            % Find the matching coefficient
            name_in_model = sprintf('%s_%s',predictor_1,categories_1{n});
            I = ismember(mdl.CoefficientNames,name_in_model);
            assert(sum(I) == 1,'Coefficient names was not correctly predicted.');

            % Comparing the current group (the intercept)
            comparison_1(p_cnt,1) = categories_1(1);
            % to whatever coefficient found.
            comparison_2(p_cnt,1) = categories_1(n);

            p_value(p_cnt,1) = mdl.Coefficients.pValue(I);

            p_cnt = p_cnt + 1;
        end

        % Aggregate p_values.
        pval = table(comparison_1,comparison_2,p_value);
        p_values = cat(1,p_values,pval);

        %% Shift the categories to change the intercept for next loop.
        categories_1 = circshift(categories_1,-1);
        tbl.(predictor_1) = setcats(tbl.(predictor_1),categories_1);

        cnt = cnt + 1;
    end
else
    %% Output 2 predictors.
    categories_1 = categories(tbl.(predictor_1));
    categories_2 = categories(tbl.(predictor_2));

    N = length(categories_1)*length(categories_2);

    estimates = table;
    estimates.predictor_1 = categorical(repmat({''},N,1));
    estimates.predictor_2 = categorical(repmat({''},N,1));
    for i = 1:length(count_groups)
        estimates.(['N_',count_groups{i}]) = nan(N,1);
    end
    estimates.N = zeros(N,1);
    estimates.estimate = nan(N,1);
    estimates.estimate_upper = nan(N,1);
    estimates.estimate_lower = nan(N,1);
    estimates.p_from_0 = nan(N,1);

    cnt = 1;
    begonia.logging.backwrite();
    for i = 1:length(categories_1)
        for j = 1:length(categories_2)
            %% Run the model.
            begonia.logging.backwrite(1,'shifting (%d/%d)',cnt,N);

            % The intercept is the first category of the predictors.
            estimates.predictor_1(cnt) = categories_1(1);
            estimates.predictor_2(cnt) = categories_2(1);
            estimates.N(cnt) = sum( ...
                tbl.(predictor_1) == categories_1(1) & ...
                tbl.(predictor_2) == categories_2(1) ...
                );
            
            for k = 1:length(count_groups)
                I = tbl.(predictor_1) == categories_1(1) & ...
                    tbl.(predictor_2) == categories_2(1);
                estimates.(['N_',count_groups{k}])(cnt) = ...
                    length(unique(tbl.(count_groups{k})(I)));
            end

            % Skip if what should be the intercept does not have any
            % samples. 
            if estimates.N(cnt) == 0
                % Shift the categories to change the intercept for next loop.
                categories_2 = circshift(categories_2,-1);
                tbl.(predictor_2) = setcats(tbl.(predictor_2),categories_2);
                cnt = cnt + 1;
                continue;
            end

            % Run the model.
            mdl = model_function(tbl);
            
            % Extract estimates and error.
            estimates.estimate(cnt) = link_function(mdl.Coefficients.Estimate(1));
            estimates.estimate_upper(cnt) = ...
                link_function(mdl.Coefficients.Estimate(1) + mdl.Coefficients.SE(1));
            estimates.estimate_lower(cnt) = ...
                link_function(mdl.Coefficients.Estimate(1) - mdl.Coefficients.SE(1));
            estimates.p_from_0(cnt) = mdl.Coefficients.pValue(1);

            %% Find p-values
            comparison_1 = categorical;
            comparison_2 = categorical;
            p_value = nan(0,1);

            p_cnt = 1;

            % Look for matches to categories_1
            % Skipping the intercept by starting at n=2.
            for n = 2:length(categories_1)
                % Find the matching coefficient
                name_in_model = sprintf('%s_%s',predictor_1,categories_1{n});
                I = ismember(mdl.CoefficientNames,name_in_model);
                assert(sum(I) == 1,'Coefficient names was not correctly predicted.');

                % Comparing the current group (the intercept)
                comparison_1(p_cnt,1) = categories_1(1);
                comparison_1(p_cnt,2) = categories_2(1);
                % to whatever coefficient found.
                comparison_2(p_cnt,1) = categories_1(n);
                comparison_2(p_cnt,2) = categories_2(1);

                p_value(p_cnt,1) = mdl.Coefficients.pValue(I);

                p_cnt = p_cnt + 1;
            end

            % Look for matches to categories_2
            % Skipping the intercept by starting at n=2.
            for n = 2:length(categories_2)
                % Find the matching coefficient
                name_in_model = sprintf('%s_%s',predictor_2,categories_2{n});
                I = ismember(mdl.CoefficientNames,name_in_model);
                assert(sum(I) == 1,'Coefficient names was not correctly predicted.');

                % Comparing the current group (the intercept)
                comparison_1(p_cnt,1) = categories_1(1);
                comparison_1(p_cnt,2) = categories_2(1);
                % to whatever coefficient found.
                comparison_2(p_cnt,1) = categories_1(1);
                comparison_2(p_cnt,2) = categories_2(n);

                p_value(p_cnt,1) = mdl.Coefficients.pValue(I);

                p_cnt = p_cnt + 1;
            end

            % Aggregate p_values.
            pval = table(comparison_1,comparison_2,p_value);
            p_values = cat(1,p_values,pval);
            
            %% Shift the categories to change the intercept for next loop.
            categories_2 = circshift(categories_2,-1);
            tbl.(predictor_2) = setcats(tbl.(predictor_2),categories_2);

            cnt = cnt + 1;
        end

        %% Shift the categories to change the intercept for next loop.
        categories_1 = circshift(categories_1,-1);
        tbl.(predictor_1) = setcats(tbl.(predictor_1),categories_1);
    end
end
%% Find duplicate p values.
if isempty(predictor_2)
    comp1 = p_values.comparison_1;
    comp2 = p_values.comparison_2;
else
    comp1 = p_values.comparison_1(:,1) .* p_values.comparison_1(:,2);
    comp2 = p_values.comparison_2(:,1) .* p_values.comparison_2(:,2);
end

X = [comp1,comp2];
X = sort(X,2);
X = X(:,1) .* X(:,2);

I = false(size(p_values,1),1);
strange_p_values = [];

[U,Xi,Ui] = unique(X);

for i = 1:length(U)
    J = find(Ui == i);
    assert(length(J) == 2);
    
    % Remove the second identical p-value. 
    I(J(2)) = true;
    
    % Check if the pvalues are the same, they should.
    val1 = round(p_values.p_value(J(1)),4,'significant');
    val2 = round(p_values.p_value(J(2)),4,'significant');
    
    if val1 ~= val2
        strange_p_values(end+1) = J(1);
        strange_p_values(end+1) = J(2);
    end
end

if ~isempty(strange_p_values)
    warning('The following comparisons are identical but have different p-values : ');
    p_values(strange_p_values,:)
end
% And remove them
p_values(I,:) = [];

end

