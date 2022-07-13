function [mu,sigma] = heatmap_correlation(tbl,state_1,state_2)
%% Find all the valid comparisons
N = height(tbl);
comparisons = nan(N * N,2);
I = tbl.state' == state_1;
I = find(I);

cnt = 0;
for i = I
    % false in the following comparisons represents an invalid comparison.
    % Only compare the same FOV.
    J = tbl.fov_id(i) == tbl.fov_id';
    % Only compare the correct states
    J = J & state_2 == tbl.state';
    % If the state is the same, do not compare more than once
    if isequal(state_1,state_2)
        J = J & i < 1:N;
    end
    % Never compare to self
    J(i) = false;
    
    J = find(J);
    
    for j = J
        cnt = cnt + 1;
        
        comparisons(cnt,1) = i;
        comparisons(cnt,2) = j;
    end
end

comparisons = comparisons(1:cnt,:);
%% Calculate coeff
correlation = nan(size(comparisons,1),1);
fov_id = nan(size(comparisons,1),1);
s_1 = cell(size(comparisons,1),1);
s_2 = cell(size(comparisons,1),1);

begonia.util.logging.backwrite();
for idx = 1:size(comparisons,1)
    begonia.util.logging.backwrite(1,'comparing %s to %s (%d/%d)',state_1,state_2,idx,size(comparisons,1));
    
    i = comparisons(idx,1);
    j = comparisons(idx,2);
    
    img_1 = tbl.img_roa_frequency{i};
    img_2 = tbl.img_roa_frequency{j};
        
%     img_intersect = min(img_1,img_2);
%     img_union = max(img_1,img_2);
%     c = sum(img_intersect(:))/sum(img_union(:));
    c = corr(img_1(:),img_2(:));
    
    correlation(idx) = c;
    fov_id(idx) = tbl.fov_id(i);
    s_1{idx} = char(tbl.state(i));
    s_2{idx} = char(tbl.state(j));
end
%% Output

state_1 = s_1;
state_2 = s_2;

I = isnan(correlation);
if any(I)
    begonia.util.logging.vlog(1,sprintf('Found %d NaN coefficents, ignoring.',sum(I)));
end

N = sum(~I);
mu = nanmean(correlation);
sigma = nanstd(correlation)/sqrt(N);

tbl = table(fov_id,state_1,state_2,correlation);
tbl.state_1 = categorical(tbl.state_1);
tbl.state_2 = categorical(tbl.state_2);
tbl(I,:) = [];
% tbl
% begonia.util.logging.vlog(1,sprintf('correlation mean : %f',mu));
% begonia.util.logging.vlog(1,sprintf('correlation sem  : %f',sigma));

end