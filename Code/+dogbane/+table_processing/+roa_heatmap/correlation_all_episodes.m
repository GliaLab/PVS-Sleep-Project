function tbl_out = correlation_all_episodes(tbl)

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

n = 1;
begonia.util.logging.backwrite();
for i = 1:height(tbl)
    for j = i+1:height(tbl)
        if tbl.fov_id(i) ~= tbl.fov_id(j)
            continue;
        end
        begonia.util.logging.backwrite(1,'%d/%d',n,N);

        img_1 = tbl.img_roa_frequency{i};
        img_2 = tbl.img_roa_frequency{j};
        
        img_1 = img_1(:);
        img_2 = img_2(:);

        I = tbl.roa_ignore_mask{i}(:);
        img_1(I) = [];
        img_2(I) = [];
        
%         I = (img_1 + img_2) == 0;
%         img_1(I) = [];
%         img_2(I) = [];
        
        R = corrcoef(img_1,img_2);

        coeff(n) = R(1,2);
        
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

state_1 = combination(:,1);
state_2 = combination(:,2);

combination = state_1 .* state_2;

tbl_out = table(ep_idx,fov_id,combination,state_1,state_2,coeff);

tbl_out(isnan(tbl_out.coeff),:) = [];

[~,genotype,mouse,fov_id] = findgroups(tbl.genotype, ...
    tbl.mouse,tbl.fov_id);
assert(length(unique(fov_id)) == length(fov_id));
tbl_id = table(genotype,mouse,fov_id);
tbl_out = innerjoin(tbl_id,tbl_out);

end

