function L2 = distance_norm_all_to_all(tbl)

begonia.util.logging.vlog(1,'Converting to images')
imgs = cellfun(@(x)x(:),tbl.img_roa_density,'UniformOutput',false);
imgs = cat(2,imgs{:})';
imgs = imgs./max(imgs,1);


begonia.util.logging.vlog(1,'Calculating distance.')
n = 1;
L2 = zeros(height(tbl),height(tbl));

i_len = height(tbl);

begonia.util.logging.backwrite();
for i = 1:height(tbl)
    begonia.util.logging.backwrite(1,'%d/%d',i,i_len);
    
    for j = i:height(tbl)
        img_1 = imgs(i,:);
        img_2 = imgs(j,:);
        l2 = sqrt(sum((img_1 - img_2).^2));
        L2(i,j) = l2;
        L2(j,i) = l2;
    end
end

end

