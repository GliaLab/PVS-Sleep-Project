function calc_average_images(ts)

trial_id = string(ts.load_var("trial_id"));
average_images = table;
average_images.trial_id(:) = repmat(trial_id, ts.channels, 1);
average_images.channel = (1:ts.channels)';
for ch = 1:ts.channels
    mat = ts.get_mat(ch);
    
    if ts.frame_count > 2000
        average_images.img{ch} = mean(mat(:,:,1000:2000), 3);
    else
        average_images.img{ch} = mean(mat(:,:,:), 3);
    end
end

ts.save_var(average_images);

end

