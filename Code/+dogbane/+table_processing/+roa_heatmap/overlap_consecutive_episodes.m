function [tbl_out,used] = overlap_consecutive_episodes(tbl,overlap_percent)

p = 100 - overlap_percent;

N = 0;
for i = 2:height(tbl)
    if tbl.trial_id(i) == tbl.trial_id(i-1)
        N = N + 1;
    end
end


fov_id = zeros(N,1);
state_1 = cell(N,1);
state_2 = cell(N,1);
coeff = nan(N,1);

% Indices indicating which episodes has been used in the calculation. 
used = false(height(tbl),1);

n = 1;
begonia.util.logging.backwrite();
for i = 2:height(tbl)
    if tbl.trial_id(i) ~= tbl.trial_id(i-1)
        continue;
    end
    begonia.util.logging.backwrite(1,'%d/%d',n,N);
    
    img_1 = tbl.img_roa_frequency{i-1};
    img_2 = tbl.img_roa_frequency{i};
    
    % Set the activity of removed areas to 0. This way they will be
    % ignored.
    I = tbl.roa_ignore_mask{i-1}(:);
    img_1(I) = 0;
    I = tbl.roa_ignore_mask{i}(:);
    img_2(I) = 0;
    
    % Find active regions above a percentile
    I = img_1(:) ~= 0;
    img_1 = img_1 >= prctile(img_1(I),p);
    
    % Find active regions above a percentile
    I = img_2(:) ~= 0;
    img_2 = img_2 >= prctile(img_2(I),p);
    
    img_intersect = min(img_1,img_2);
    img_union = max(img_1,img_2);
    
    coeff(n) = sum(img_intersect(:))/sum(img_union(:));
    
    state_1{n} = char(tbl.state(i-1));
    state_2{n} = char(tbl.state(i));
    fov_id(n) = tbl.fov_id(i);
    
    n = n + 1;
    
    used(i) = true;
    used(i-1) = true;
end

state_1 = categorical(state_1);
state_2 = categorical(state_2);

tbl_out = table(fov_id,state_1,state_2,coeff);

end

