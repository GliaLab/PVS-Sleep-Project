function [mat,var1_rows,var2_cols] = unstack(data,var1,var2,aggregation_function)
if nargin < 4
    aggregation_function = [];
end

assert(isnumeric(data))
if iscellstr(var1)
    var1 = categorical(var1);
end
if iscellstr(var2)
    var2 = categorical(var2);
end

if iscategorical(var1)
    var1_rows = categories(var1);
else
    var1_rows = unique(var1);
end
if iscategorical(var2)
    var2_cols = categories(var2)';
else
    var2_cols = unique(var2)';
end

mat = nan(length(var1_rows),length(var2_cols));

for j = 1:length(var2_cols)
    for i = 1:length(var1_rows)
        indices_1 = var1 == var1_rows(i);
        indices_2 = var2 == var2_cols(j);
        indices = indices_1 & indices_2;
        samples = sum(indices);
        if isempty(aggregation_function)
            switch samples
                case 0
                    val = nan;
                case 1
                    val = data(indices);
                otherwise
                    error('Aggregation function needed to handle multiple samples in the same category.');
            end
        else
            val = aggregation_function(data(indices));
        end
        mat(i,j) = val;
    end
end

end