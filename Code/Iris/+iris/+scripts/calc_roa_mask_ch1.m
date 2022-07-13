clear all

%% Load tseries
ts = get_tseries(true);
ts = ts(ts.has_var("trial_id"));

%%

channel = 1;

% All roa parameters.
roa_t_smooth = 1; % Temporal box smoothing (minimum 1 frame).
roa_xy_smooth = 1.2; % Spatial gaussian smoothing.
roa_ignore_border = 15;
roa_threshold = 4; % std threshold.
roa_min_size = 3*3; % Minimum pixel size.
roa_min_duration = 1; % Minimum frame duration.

assert(roa_t_smooth == round(roa_t_smooth), "roa_t_smooth must be an integer.");

for i = 1:length(ts)
    begonia.logging.log(1,"%d / %d : %s",i,length(ts),ts(i).load_var("trial_id"));
    
    % Load (lazy) data.
    mat = ts(i).get_mat(channel);

    % Define the spatial smoothing kernel.
    spatial_filter_vec = begonia.util.gausswin(roa_xy_smooth);
    spatial_filter_vec = spatial_filter_vec .* spatial_filter_vec';
    spatial_filter_vec = spatial_filter_vec ./ sum(spatial_filter_vec(:));
    spatial_filter_vec = single(spatial_filter_vec);

    % Define alternative standard deviation measurement.
    std_alt = @(x) sqrt(median(diff(x,1,3).^2,3)/0.9099);

    % Calculate img_mu and img_sigma in chunks.
    roa_img_mu = zeros(ts(i).img_dim);
    roa_img_sigma = zeros(ts(i).img_dim);
    % Pad with half size of the kernel. 
    padding = (size(spatial_filter_vec,1) - 1 ) / 2;
    c = begonia.util.Chunker(mat,'chunk_padding',padding,'data_type','single','chunk_axis',2);
    for j = 1:c.chunks
        begonia.logging.log(1,'Calculating img_sigma and img_mu chunk (%d/%d)',j,c.chunks);
        mat_sub = c.chunk(j);
    
        % Temporal smooth.
        if roa_t_smooth > 1
            mat_sub = begonia.util.stepping_window(mat_sub,roa_t_smooth,[],[],'single');
        else
            mat_sub = single(mat_sub(:,:,:));
        end

        % Spatial smooth.
        if roa_xy_smooth > 0
            mat_sub = convn(mat_sub,spatial_filter_vec,'same');
        end
        % Variance stabilisation.
        mat_sub = sqrt(mat_sub);
        % Round to nearest hundreth for mode calculation.
        mat_sub = round(mat_sub,2);
        % Remove the padding added to the chunk.
        mat_sub = c.unpad(mat_sub,j);
        
        % Calculate mu and sigma.
        I = c.chunk_indices_no_pad(j);
        roa_img_mu(I{:}) = mode(mat_sub, 3);
        roa_img_sigma(I{:}) = std_alt(mat_sub);
    end

    % Estimate SNR for fun.
    sigma = median(roa_img_sigma(:));
    median_snr = median(roa_img_mu(:)) ./ sigma;
    begonia.logging.log(1,"Estimated SNR : %f", median_snr);
    
    % Define the filter, this time temporal and spatial together. 
    filter_vec = begonia.util.gausswin(roa_xy_smooth);
    filter_vec = filter_vec .* filter_vec' .* ones(1,1,roa_t_smooth);
    filter_vec = filter_vec ./ sum(filter_vec(:));
    filter_vec = single(filter_vec);

    % Calculate ROA in chunks.
    c = begonia.util.Chunker(mat,'chunk_padding',roa_t_smooth,'data_type','single');
    roa_mask = false(size(mat));
    for j = 1:c.chunks
        begonia.logging.log(1,'Detecting ROA in chunk (%d/%d)',i,c.chunks);
        mat_sub = c.chunk(j);
        mat_sub = single(mat_sub);
        % Temporal and spatial smoothing.
        mat_sub = convn(mat_sub,filter_vec,'same');
        % Variance stabilisation.
        mat_sub = sqrt(mat_sub);
        % Remove the padding added to the chunk.
        mat_sub = c.unpad(mat_sub,j);

        I = c.chunk_indices_no_pad(j);
        roa_mask(I{:}) = mat_sub > roa_img_mu + roa_img_sigma * roa_threshold;
    end
    
    % Remove ignored areas.
    if roa_ignore_border > 0
        begonia.logging.log(1,"Ignore border.");
        roa_ignore_mask = false(ts(i).img_dim);
        roa_ignore_mask(1:roa_ignore_border,:) = true;
        roa_ignore_mask(end-roa_ignore_border+1:end,:) = true;
        roa_ignore_mask(:,1:roa_ignore_border) = true;
        roa_ignore_mask(:,end-roa_ignore_border+1:end) = true;
        roa_mask = roa_mask & ~roa_ignore_mask;
    end

    % Filter small ROA
    if roa_min_size > 0
        begonia.logging.log(1,'Filtering small ROA.');
        CC = bwconncomp(roa_mask, 4);
        num_pixels = cellfun(@numel,CC.PixelIdxList);
        idx = find(num_pixels < roa_min_size);
        for j = idx
            roa_mask(CC.PixelIdxList{j}) = false;
        end
    end
    
    % Filter short ROA.
    begonia.logging.log(1,'Filtering short ROA.');
    if roa_min_duration
        CC = bwconncomp(roa_mask,6);
        for j = 1:CC.NumObjects
            [x,y,t] = ind2sub(CC.ImageSize,CC.PixelIdxList{j});
            if length(unique(t)) < roa_min_duration
                roa_mask(CC.PixelIdxList{j}) = false;
            end
        end
    end
    
    % Save ROA.
    begonia.logging.log(1,"Saving roa_mask.");
    ts(i).save_var(roa_mask);

    % Save parameters.
    roa_param = table;
    roa_param.channel = channel;
    roa_param.roa_t_smooth = roa_t_smooth;
    roa_param.roa_xy_smooth = roa_xy_smooth;
    roa_param.roa_ignore_border = roa_ignore_border;
    roa_param.roa_threshold = roa_threshold;
    roa_param.roa_min_size = roa_min_size;
    roa_param.roa_min_duration = roa_min_duration;
    roa_param.fs = 1 / ts(i).dt;
    roa_param.dx = ts(i).dx;
    roa_param.dim = size(roa_mask);
    ts(i).save_var(roa_param);
end
begonia.logging.log(1,"ROA finished");
