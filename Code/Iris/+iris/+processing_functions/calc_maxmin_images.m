function calc_maxmin_images(ts)

min_images = table;
min_images.channel = (1:ts.channels)';
max_images = table;
max_images.channel = (1:ts.channels)';
for ch = 1:ts.channels
    mat = ts.get_mat(ch);
    mat = mat(:,:,:);
    max_images.img{ch} = max(mat, [], 3);
    min_images.img{ch} = min(mat, [], 3);
end
ts.save_var(max_images);
ts.save_var(min_images);

end

