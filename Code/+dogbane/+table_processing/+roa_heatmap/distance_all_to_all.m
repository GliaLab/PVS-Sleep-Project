function [L1,L2] = distance_all_to_all(tbl)

begonia.util.logging.vlog(1,'Converting to images')
imgs = cellfun(@(x)x(:),tbl.img_roa_density,'UniformOutput',false);
imgs = cat(2,imgs{:})';

begonia.util.logging.vlog(1,'Calculating distance.')
n = 1;
L1 = zeros(height(tbl),height(tbl));
L2 = zeros(height(tbl),height(tbl));

i_len = height(tbl);

begonia.util.logging.backwrite();
for i = 1:height(tbl)
    begonia.util.logging.backwrite(1,'%d/%d',i,i_len);
    
    for j = i:height(tbl)
        img_1 = imgs(i,:);
        img_2 = imgs(j,:);
        l1 = sum(abs(img_1 - img_2));
        l2 = sqrt(sum((img_1 - img_2).^2));
        L1(i,j) = l1;
        L1(j,i) = l1;
        L2(i,j) = l2;
        L2(j,i) = l2;
    end
end

end

