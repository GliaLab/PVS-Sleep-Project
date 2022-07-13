function roa_mask(ts)

mat = ts.get_mat(1,1);
mat = mat(:,:,:);
mat = single(mat);

% Spatial filter
spatial_filter_half_width = 2;
filter_spatial = ones(1+2*spatial_filter_half_width,1+2*spatial_filter_half_width,'single');
filter_spatial = filter_spatial./sum(filter_spatial(:));

begonia.util.logging.vlog(2,'Spatial smoothing');
mat = convn(mat,filter_spatial,'same');
% ROA
threshold = 6;
temporal_filter_half_width = ceil(0.5/ts.dt); % 0.5 seconds
[roa_mask,img_f0,img_sigma] = ...
    begonia.processing.roa_mask(mat,temporal_filter_half_width,threshold);

ts.save_var(roa_mask);
ts.save_var(img_f0);
ts.save_var(img_sigma);
end

