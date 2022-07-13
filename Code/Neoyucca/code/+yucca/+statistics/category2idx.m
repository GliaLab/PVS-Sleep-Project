function I = category2idx(cats,categories_1,categories_2)
% I = category2idx(
if nargin == 1
    categories_1 = categories(cats);
end

if nargin <= 2
    [~,I] = ismember(cats,categories_1);
    return;
end

I = zeros(size(cats,1),1);

categories_1 = categorical(categories_1);
categories_2 = categorical(categories_2);

for i = 1:size(cats,1)    
    row = [];
    for j = 1:length(cats(i,:))
        row = find(categories_1 == cats(i,j));
        if ~isempty(row); break; end
    end
    assert(~isempty(row),'Category in combination not in dimension 1 categories.')
    
    
    col = [];
    for j = 1:length(cats(i,:))
        col = find(categories_2 == cats(i,j));
        if ~isempty(col); break; end
    end
    assert(~isempty(col),'Category in combination not in dimension 2 categories.')
    
    I(i) = (row-1)*length(categories_2) + col;
end


end

