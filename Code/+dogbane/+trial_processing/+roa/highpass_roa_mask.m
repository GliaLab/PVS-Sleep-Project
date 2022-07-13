function highpass_roa_mask(ts)

mat = ts.get_mat(1,1);
mat = mat(:,:,:);
mat = single(mat);

%% Spatial filter
spatial_filter_half_width = 2;
filter_spatial = ones(1+2*spatial_filter_half_width,1+2*spatial_filter_half_width,'single');
filter_spatial = filter_spatial./sum(filter_spatial(:));

begonia.util.logging.vlog(2,'Spatial smoothing');
mat = convn(mat,filter_spatial,'same');
%% ROA
threshold = 5;
temporal_hp_filter_half_width = ceil(10.0/ts.dt); % 10 seconds on each side.
temporal_filter_half_width = ceil(0.5/ts.dt); % 0.5 seconds
[highpass_roa_mask,highpass_img_f0,highpass_img_sigma] = ...
    begonia.processing.roa_mask_highpass(mat,temporal_filter_half_width,threshold,temporal_hp_filter_half_width);

ts.save_var(highpass_roa_mask);
ts.save_var(highpass_img_f0);
ts.save_var(highpass_img_sigma);
end

