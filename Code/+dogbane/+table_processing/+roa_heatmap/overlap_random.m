function overlap = overlap_random(overlap,heatmaps,num_random_samples)

assert(mod(num_random_samples,2) == 0,'Number of random samples must be even.');


begonia.util.logging.vlog(1,'Converting to binary images.')
imgs = cellfun(@(x)x(:),heatmaps.img_roa_frequency,'UniformOutput',false);
imgs = cat(2,imgs{:})';
imgs = imgs > 0;

coeff_null = nan(height(overlap),num_random_samples);
possible_comparisons_1 = nan(height(overlap),1);
possible_comparisons_2 = nan(height(overlap),1);

seed = RandStream('mlfg6331_64');

begonia.util.logging.vlog(1,'Calculating the Jaccard index.')
begonia.util.logging.backwrite();
for i = 1:height(overlap)
    begonia.util.logging.backwrite(1,'%d/%d',i,height(overlap));
    
    %% Compare images with the first episode. 
    valid_episodes = heatmaps.state == overlap.state_2(i);
    valid_episodes = valid_episodes & heatmaps.fov_id ~= overlap.fov_id(i);
    valid_episodes = find(valid_episodes);
    possible_comparisons_1(i) = length(valid_episodes);
    valid_episodes = randsample(seed,valid_episodes,num_random_samples/2,true);
    
    img_1 = imgs(overlap.ep_idx(i,1),:);
    for j = 1:num_random_samples/2
        img_2 = imgs(valid_episodes(j),:);
        
        coeff_null(i,j) = sum(min(img_1,img_2))/sum(max(img_1,img_2));
    end
    
    %% Compare images with the second episode. 
    valid_episodes = heatmaps.state == overlap.state_1(i);
    valid_episodes = valid_episodes & heatmaps.fov_id ~= overlap.fov_id(i);
    valid_episodes = find(valid_episodes);
    possible_comparisons_2(i) = length(valid_episodes);
    valid_episodes = randsample(seed,valid_episodes,num_random_samples/2,true);
    
    img_1 = imgs(overlap.ep_idx(i,2),:);
    for j = 1:num_random_samples/2
        
        img_2 = imgs(valid_episodes(j),:);
        
        coeff_null(i,j+num_random_samples/2) = sum(min(img_1,img_2))/sum(max(img_1,img_2));
    end
end

overlap.possible_comparisons_1 = possible_comparisons_1;
overlap.possible_comparisons_2 = possible_comparisons_2;
overlap.coeff_null = coeff_null;
end

