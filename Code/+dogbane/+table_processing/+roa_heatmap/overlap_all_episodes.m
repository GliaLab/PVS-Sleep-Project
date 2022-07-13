function tbl_out = overlap_all_episodes(tbl)

begonia.util.logging.vlog(1,'Converting to binary images.')
imgs = cellfun(@(x)x(:),tbl.img_roa_frequency,'UniformOutput',false);
imgs = cat(2,imgs{:})';
imgs = imgs > 0;

begonia.util.logging.vlog(1,'Counting combinations.')
N = 0;
for i = 1:height(tbl)
    for j = i+1:height(tbl)
        if tbl.fov_id(i) == tbl.fov_id(j)
            N = N + 1;
        end
    end
end

fov_id = zeros(N,1);
state_1 = cell(N,1);
state_2 = cell(N,1);
ep_idx = nan(N,2);
coeff = nan(N,1);

begonia.util.logging.vlog(1,'Calculating the Jaccard index.')
n = 1;
begonia.util.logging.backwrite();
for i = 1:height(tbl)
    for j = i+1:height(tbl)
        if tbl.fov_id(i) ~= tbl.fov_id(j)
            continue;
        end
        begonia.util.logging.backwrite(1,'%d/%d',n,N);
        
        img_1 = imgs(i,:);
        img_2 = imgs(j,:);
        coeff(n) = sum(min(img_1,img_2))/sum(max(img_1,img_2));

%         img_1 = tbl.img_roa_frequency{i};
%         img_2 = tbl.img_roa_frequency{j};
% 
%         % Set the activity of removed areas to 0. This way they will be
%         % ignored.
%         I = tbl.roa_ignore_mask{i}(:);
%         img_1(I) = 0;
%         I = tbl.roa_ignore_mask{j}(:);
%         img_2(I) = 0;
% 
%         % Find active regions above a percentile
%         I = img_1(:) ~= 0;
%         img_1 = img_1 >= prctile(img_1(I),p);
% 
%         % Find active regions above a percentile
%         I = img_2(:) ~= 0;
%         img_2 = img_2 >= prctile(img_2(I),p);
% 
%         img_intersect = min(img_1,img_2);
%         img_union = max(img_1,img_2);
% 
%         coeff(n) = sum(img_intersect(:))/sum(img_union(:));
        
        ep_idx(n,1) = i;
        ep_idx(n,2) = j;
        state_1{n} = char(tbl.state(i));
        state_2{n} = char(tbl.state(j));
        fov_id(n) = tbl.fov_id(i);

        n = n + 1;
    end
end

state_1 = categorical(state_1);
state_2 = categorical(state_2);

combination = sort([state_1,state_2],2);
combination = combination(:,1) .* combination(:,2);

tbl_out = table(ep_idx,fov_id,combination,state_1,state_2,coeff);

[~,genotype,mouse,fov_id] = findgroups(tbl.genotype, ...
    tbl.mouse,tbl.fov_id);
assert(length(unique(fov_id)) == length(fov_id));
tbl_id = table(genotype,mouse,fov_id);
tbl_out = innerjoin(tbl_id,tbl_out);

end

