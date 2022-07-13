function [estimates,p_table,N,model] = model_to_values(tbl,model_func,log_transform,response,predictor_1,predictor_2)

tbl = begonia.util.removecats_table(tbl);

I = isnan(tbl.(response));
begonia.util.logging.vlog(1,'Ignoring %d  nan-samples (%g%%)',sum(I),100*sum(I)/height(tbl));
tbl(I,:) = [];

if log_transform
    I = tbl.(response) == 0;
    begonia.util.logging.vlog(1,'Ignoring %d  zero-samples (%g%%)',sum(I),100*sum(I)/height(tbl));
    tbl(I,:) = [];
    tbl.(response) = log(tbl.(response));
end


N = begonia.util.categorical_frequency_table(tbl.(predictor_1),tbl.(predictor_2));


%% Estimate stuff
if log_transform
    link_func = @(x) exp(x);
else
    link_func = @(x) x;
end

categories_1 = categories(tbl.(predictor_1));
categories_2 = categories(tbl.(predictor_2));

N_categories_1 = length(categories_1);
N_categories_2 = length(categories_2);

pred_1 = categorical;
pred_2 = categorical;
Estimate = [];
EstimateLower = [];
EstimateUpper = [];

p_table = [];

cnt = 1;
begonia.util.logging.backwrite();
for i = 1:N_categories_1
    for j = 1:N_categories_2
        begonia.util.logging.backwrite(1,'shifting (%d/%d)',cnt,N_categories_1*N_categories_2);
        
        warning off
        model = model_func(tbl);
        warning on
        
        % The intercept is the first category of each of the fixed effects.
        % Get the categories of the intercept and the estimates. 
        pred_1(cnt,1) = categories_1(1);
        pred_2(cnt,1) = categories_2(1);
        Estimate(cnt,1) = link_func(model.Coefficients.Estimate(1));
        EstimateUpper(cnt,1) = link_func(model.Coefficients.Estimate(1) + model.Coefficients.SE(1)) - Estimate(cnt);
        EstimateLower(cnt,1) = link_func(model.Coefficients.Estimate(1) - model.Coefficients.SE(1)) - Estimate(cnt);
        
        % Get the p values using a custom function. 
        p_table_part = dogbane.util.glme_p_values_to_categories(model,categories_2,categories_1);
        p_table = cat(1,p_table,p_table_part);
        
        categories_2 = circshift(categories_2,-1);
        tbl.(predictor_2) = setcats(tbl.(predictor_2),categories_2);
        
        cnt = cnt + 1;
    end
    
    categories_1 = circshift(categories_1,-1);
    tbl.(predictor_1) = setcats(tbl.(predictor_1),categories_1);
end

EstimateLower = abs(EstimateLower);
EstimateUpper = abs(EstimateUpper);

estimates = table(pred_1,pred_2,Estimate,EstimateLower,EstimateUpper);
estimates.Properties.VariableNames = {predictor_1,predictor_2,'Estimate','EstimateLower','EstimateUpper'};
%% Find duplicate p values.
I = false(size(p_table,1),1);
for i = 1:size(p_table,1)
    for j = i+1:size(p_table,1)
        test_1 = isequal(p_table.combination_1(i,:),p_table.combination_2(j,:));
        test_2 = isequal(p_table.combination_1(j,:),p_table.combination_2(i,:));
        I(j) = I(j) | (test_1 & test_2);
    end
end
% And remove them
p_table = p_table(~I,:);

end