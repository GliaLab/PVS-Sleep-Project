function mat_out = merge_frames(mat,merged_frames)

frames_final = floor(size(mat,2) / merged_frames);

% Make the number of frames a multiple of the window length. 
mat = mat(:,1:frames_final*merged_frames);

mat = reshape(mat,size(mat,1),merged_frames,[]);
mat = mean(mat,2);
mat_out = squeeze(mat);

end

