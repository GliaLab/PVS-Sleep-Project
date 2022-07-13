function groups = combination2group(combinations,categories_dim_1,categories_dim_2)
% Groups are counted in row major order because those are the groups that
% matlab assigns indices in the bar plot.
% This assumes the categories of the column and rows are all unique from
% each other. 

groups = zeros(size(combinations,1),1);

categories_dim_1 = categorical(categories_dim_1);
categories_dim_2 = categorical(categories_dim_2);


for i = 1:size(combinations,1)
    
    row = [];
    for j = 1:length(combinations(i,:))
        row = find(categories_dim_1 == combinations(i,j));
        if ~isempty(row); break; end
    end
    assert(~isempty(row),'Category in combination not in dimension 1 categories.')
    
    
    col = [];
    for j = 1:length(combinations(i,:))
        col = find(categories_dim_2 == combinations(i,j));
        if ~isempty(col); break; end
    end
    assert(~isempty(col),'Category in combination not in dimension 2 categories.')
    
    groups(i) = (row-1)*length(categories_dim_2) + col;
end


end

