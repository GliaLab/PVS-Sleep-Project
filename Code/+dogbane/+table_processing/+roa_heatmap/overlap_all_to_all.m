function coeff = overlap_all_to_all(tbl)

begonia.util.logging.vlog(1,'Converting to binary images.')
imgs = cellfun(@(x)x(:),tbl.img_roa_frequency,'UniformOutput',false);
imgs = cat(2,imgs{:})';
imgs = imgs > 0;

begonia.util.logging.vlog(1,'Calculating the Jaccard index.')
N = height(tbl) * height(tbl);
n = 1;
coeff = zeros(height(tbl),height(tbl));

begonia.util.logging.backwrite();
for i = 1:height(tbl)
    for j = 1:height(tbl)
        begonia.util.logging.backwrite(1,'%d/%d',n,N);
        
        img_1 = imgs(i,:);
        img_2 = imgs(j,:);
        coeff(i,j) = sum(min(img_1,img_2))/sum(max(img_1,img_2));

        n = n + 1;
    end
end

end

