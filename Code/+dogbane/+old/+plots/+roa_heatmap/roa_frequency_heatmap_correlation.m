function tbl = roa_frequency_heatmap_correlation(tbl_roa_heatmap_per_episode)

% If the fov_offset is large it is usually a mistake by the detection
% algorithm. Remove these trials. 
fov_offset_dist = rssq(tbl_roa_heatmap_per_episode.fov_offset,2);
% Remove trials that must be moved more than 25 pixels. 
I = fov_offset_dist > 25; 
tbl_roa_heatmap_per_episode(I,:) = [];

% Remove trials shorter than 20 seconds.
% tbl_roa_heatmap_per_episode(tbl_roa_heatmap_per_episode.state_duration < 5,:) = [];

% Align identical FOVs by a pre-calculated offset
for i = 1:height(tbl_roa_heatmap_per_episode)
    tbl_roa_heatmap_per_episode.img_roa_frequency{i} = circshift( ...
        tbl_roa_heatmap_per_episode.img_roa_frequency{i}, ...
        tbl_roa_heatmap_per_episode.fov_offset(i,:));
end


% Crop FOVs to the same size and also crop so only the middle part of the 
% image is included. This is to avoid edge effects of aligning via 
% fov_offset.
edge_ignore = 25; % Pixels.
dim_1 = cellfun(@(x)size(x,1),tbl_roa_heatmap_per_episode.img_roa_frequency);
dim_1 = min(dim_1);
dim_2 = cellfun(@(x)size(x,2),tbl_roa_heatmap_per_episode.img_roa_frequency);
dim_2 = min(dim_2);
tbl_roa_heatmap_per_episode.img_roa_frequency = cellfun( ...
    @(x){x(edge_ignore:dim_1-edge_ignore,edge_ignore:dim_2-edge_ignore)}, ...
    tbl_roa_heatmap_per_episode.img_roa_frequency);

% for binary overlap
tbl_roa_heatmap_per_episode.img_roa_frequency = cellfun( ...
    @(x){x > 0}, ...
    tbl_roa_heatmap_per_episode.img_roa_frequency);

tbl_roa_heatmap_per_episode.avg_img = cellfun( ...
    @(x){x(edge_ignore:dim_1-edge_ignore,edge_ignore:dim_2-edge_ignore)}, ...
    tbl_roa_heatmap_per_episode.avg_img);

% Change the label quiet_awakening to quiet.
I = tbl_roa_heatmap_per_episode.state == 'quiet_awakening';
tbl_roa_heatmap_per_episode.state(I) = 'quiet';

%%
states_1 = {'quiet','nrem','is','rem'};
states_2 = states_1;

o = struct;
cnt = 1;
for i = 1:length(states_1)
    for j = 1:length(states_2)
        if i < j
            continue;
        end
        
        [mu,sigma,N] = alyssum_v2.plots_from_tables.roa_heatmap. ...
            roa_frequency_heatmap_correlation_subfunc(tbl_roa_heatmap_per_episode,states_1{i},states_2{j});
        
        o(cnt).state_1 = states_1{i};
        o(cnt).state_2 = states_2{j};
        o(cnt).corr_coef_mean = mu;
        o(cnt).corr_coef_sem = sigma;
        o(cnt).samples = N;
        
        cnt = cnt + 1;
    end
end

tbl = struct2table(o,'AsArray',true);

end

