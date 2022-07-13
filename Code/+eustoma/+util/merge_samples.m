function mat_out = merge_samples(mat,merged_samples)

samples_final = floor(size(mat,1) / merged_samples);

% Make the number of samples a multiple of merged_samples. 
mat = mat(1:samples_final*merged_samples,:);

mat = reshape(mat,merged_samples,[]);
mat = mean(mat,1);
mat_out = reshape(mat,samples_final,[]);

end

