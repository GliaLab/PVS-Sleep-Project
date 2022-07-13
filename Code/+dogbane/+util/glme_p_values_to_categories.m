function data = glme_p_values_to_categories(glme,varargin)
% This function is ment to extract the p values from the glme model. 
%   It was created to extract the p_values of 2 fixed effects, but could
% possibly work with 1 fixed effect. 
%   The output is a table with 3 columns. The first column is the
% combination of fixed effects categories that define the intercept. The
% second column is the combination of fixed effects categories that
% defines the second group that the p value is compared to. 
% 
% 2 fixed effects. 
%   data = glme_p_values_to_categories(glme,fixed_effects_group_1,fixed effects_group_2)
% 1 fixed effect. 
%   data = glme_p_values_to_categories(glme,fixed_effects_group_1)
%

%% Parse input
assert(length(varargin) <= 2, 'Only supports up to 2 groups (for now).')
% Each element in varargin should be a list of categories, either cell or
% categorical. 
groups = {};
% Convert whatever input to categorical. 
for i = 1:length(varargin)
    c = varargin{i};
    if iscolumn(c); c = reshape(c,1,[]); end
    groups{i} = categorical(c);
end

%% Define intercept. 
% Find the intercept as the first category in each group. 
intercept = categorical();
for i = 1:length(groups)
    intercept(i) = groups{i}(1);
end

% This commented code chunk didnt do the job well enough.
% % Find the intercept by looking for the only category not described in any
% % of the coefficient names. 
% described_in_coeff_name = {};
% for i = 1:length(groups)
%     described_in_coeff_name{i} = false(1,length(groups{i}));
% end
% 
% for i = 1:length(glme.CoefficientNames)
%     
%     name = glme.CoefficientNames{i};
%     % Remove the group name of the name, so we can match the categories
%     % exactly (here we assume the category names are unique).
%     for j = 1:length(glme.VariableNames)
%         name = strrep(name,[glme.VariableNames{j},'_'],'');
%     end
%     
%     skip = false;
%     skip = skip | contains(name,'Intercept');
%     skip = skip | contains(name,':');
%     if skip; continue; end
%     
%     for j = 1:length(groups)
%         I = strcmp(name,cellstr(groups{j}));
%         described_in_coeff_name{j} = described_in_coeff_name{j} | I;
%     end
%     
% end
% 
% % Define the intercept
% intercept = categorical;
% for i = 1:length(described_in_coeff_name)
%     I = ~described_in_coeff_name{i};
%     switch sum(I)
%         case 1
%             intercept(i) = groups{i}(I);
%         case 0
%             error('Could not find intercept (wrong input groups?)');
%         otherwise
%             error('Could not find intercept (multiple categories was not mentioned in the coefficient names.');
%     end
%         
% end

%% Parse each row of the glme
combination_1 = categorical();
combination_2 = categorical();
p_values = [];

cnt = 1;
for i = 1:length(glme.CoefficientNames)
    
    name = glme.CoefficientNames{i};
    % Remove the group name of the name, so we can match the categories
    % exactly (here we assume the category names are unique).
    for j = 1:length(glme.VariableNames)
        name = strrep(name,[glme.VariableNames{j},'_'],'');
    end
    %% Decide if this row has a p_value we want, skip if it doesnt. 
    skip = false;
    skip = skip | contains(name,'Intercept');
    skip = skip | contains(name,':');
    if skip; continue; end
    %% Find which 2 combinations the p_value are comparing. 
    combination_1(cnt,:) = intercept;
    
    % Find the which group and category is described in the name. 
    combination_2(cnt,:) = intercept;
    for j = 1:length(groups)
        I = strcmp(name,cellstr(groups{j}));
        if sum(I) == 1
            combination_2(cnt,j) = groups{j}(I);
        end
    end
    
    %% Get the p value
    p_values(cnt,1) = glme.Coefficients.pValue(i);
    %% Increment counter. 
    cnt = cnt + 1;
end

data = table(combination_1,combination_2,p_values);

end

