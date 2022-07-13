function coeff = overlap_w_all_to_all(tbl)

begonia.util.logging.vlog(1,'Converting images.')
imgs = cellfun(@(x)x(:),tbl.img_roa_density,'UniformOutput',false);
imgs = cat(2,imgs{:})';

begonia.util.logging.vlog(1,'Calculating the weighted Jaccard index.')
coeff = zeros(height(tbl),height(tbl));

begonia.util.logging.backwrite();
for i = 1:height(tbl)
    begonia.util.logging.backwrite(1,'%d/%d',i,height(tbl));
    for j = i:height(tbl)
        img_1 = imgs(i,:);
        img_2 = imgs(j,:);
        val = sum(min(img_1,img_2))/sum(max(img_1,img_2));
        coeff(i,j) = val;
        coeff(j,1) = val;
    end
end

end

