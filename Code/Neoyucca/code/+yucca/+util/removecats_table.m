function data = removecats_table(data)
% removecats_table removes all unused categories in each categorical column.
%   
%   table_out = removecats_table(table_in)
%
%   REQUIRED
%   table_in                - (table)
%
%   RETURNED
%   table_out               - (table) without excess categories.
validateattributes(data,{'table'},{})

var_names = data.Properties.VariableNames;
data = varfun(@remove_excess_categories,data);
data.Properties.VariableNames = var_names;

end

function arr = remove_excess_categories(arr)

if iscategorical(arr) && length(arr) == 1 && isundefined(arr)
    % Using removecats on such an array can create a bug somehow.
    arr = setcats(arr,{});
    return;
end

if iscategorical(arr) 
    arr = removecats(arr);
end
end