function assign_fov_id_and_offset(tbl_img_avg)

%% Resize
dim_1 = cellfun(@(x)size(x,1),tbl_img_avg.avg_img);
dim_1 = min(dim_1);
dim_1 = min(dim_1,250);
dim_2 = cellfun(@(x)size(x,2),tbl_img_avg.avg_img);

dim_2 = min(dim_2);
dim_2 = min(dim_2,250);
tbl_img_avg.avg_img = cellfun(@(x){x(1:dim_1,1:dim_2)},tbl_img_avg.avg_img);

%%
used = false(height(tbl_img_avg),1);
fov_ids = nan(height(tbl_img_avg),1);
fov_offsets = nan(height(tbl_img_avg),2);

begonia.util.logging.backwrite();
for i = 1:height(tbl_img_avg)
    
    if used(i)
        continue;
    end
    
    fov_ids(i) = i;
    fov_offsets(i,:) = [0,0];
    
    used(i) = true;
    
    % false in the following comparisons represents an invalid comparison.
    % Do not compare more than once and not self.
    J_1 = i < 1:height(tbl_img_avg);
    % Only compare other trials within the same mouse.
    J_2 = tbl_img_avg.mouse(i) == tbl_img_avg.mouse';
    J = J_1 & J_2;
    
    J = find(J);
    
    for j = J
        begonia.util.logging.backwrite(1,sprintf('i = %d/%d - j = %d/%d',i,height(tbl_img_avg),j,height(tbl_img_avg)));
        
        c = normxcorr2(tbl_img_avg.avg_img{j},tbl_img_avg.avg_img{i});
        c_max = max(c(:));
        
        if c_max >= 0.8
            
            [ypeak, xpeak] = find(c == c_max);
            offset = [ypeak - dim_1,xpeak - dim_2];
            
            fov_ids(j) = i;
            fov_offsets(j,:) = offset;
            
            used(j) = true;
            
%             lim_1 = [0,prctile(tbl_img_avg.avg_img{i}(:),98)];
%             lim_2 = [0,prctile(tbl_img_avg.avg_img{j}(:),98)];
%             
%             im_1 = begonia.mat_functions.normalize(tbl_img_avg.avg_img{i},'type','uint8','limits',lim_1);
%             im_2 = begonia.mat_functions.normalize(tbl_img_avg.avg_img{j},'type','uint8','limits',lim_2);
%             
%             im_rgb = zeros(dim_1,dim_2,3,'uint8');
%             im_rgb(:,:,1) = im_1;
%             im_rgb(:,:,2) = im_2;
%             
%             figure;
%             imshow(im_rgb)
%             
%             
%             im_rgb(:,:,2) = circshift(im_2,offset);
%             
%             figure;
%             imshow(im_rgb)
            
            
        end
    end
end

tbl_img_avg.fov_id = fov_ids;
tbl_img_avg.fov_offset = fov_offsets;

for i = 1:height(tbl_img_avg)
    ts = tbl_img_avg.tseries{i};
    ts.clear_var('fov_id');
    ts.clear_var('fov_id_count');
    ts.clear_var('fov_offset');
    
    fov_id = tbl_img_avg.fov_id(i);
    fov_id_count = sum(tbl_img_avg.fov_id == fov_id);
    fov_offset = tbl_img_avg.fov_offset(i,:);
    
    ts.save_var(fov_id);
    ts.save_var(fov_id_count);
    ts.save_var(fov_offset);
end




end

