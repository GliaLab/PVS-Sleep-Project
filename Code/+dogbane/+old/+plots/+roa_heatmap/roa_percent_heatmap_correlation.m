function [tbl,tbl_all] = roa_percent_heatmap_correlation(tbl_roa_heatmap_per_episode,tm)

%% Remove trials that must be moved a lot.
fov_offset_dist = rssq(tbl_roa_heatmap_per_episode.fov_offset,2);
% If the fov_offset is large it is usually a mistake by the detection
% algorithm. Remove these trials. 
I = fov_offset_dist > 25; 
tbl_roa_heatmap_per_episode(I,:) = [];
%% Remove episodes which has short durations.
tbl_roa_heatmap_per_episode(tbl_roa_heatmap_per_episode.state_duration < 30,:) = [];

%% Align identical FOVs by a pre-calculated offset
for i = 1:height(tbl_roa_heatmap_per_episode)
    tbl_roa_heatmap_per_episode.img_roa_frequency{i} = circshift( ...
        tbl_roa_heatmap_per_episode.img_roa_frequency{i}, ...
        tbl_roa_heatmap_per_episode.fov_offset(i,:));
    
    tbl_roa_heatmap_per_episode.avg_img{i} = circshift( ...
        tbl_roa_heatmap_per_episode.avg_img{i}, ...
        tbl_roa_heatmap_per_episode.fov_offset(i,:));
end

%% Crop FOVs to the same size and also crop so only the middle part of the 
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

tbl_roa_heatmap_per_episode.avg_img = cellfun( ...
    @(x){x(edge_ignore:dim_1-edge_ignore,edge_ignore:dim_2-edge_ignore)}, ...
    tbl_roa_heatmap_per_episode.avg_img);
%% Change the heatmaps into binary images based on a set percent active pixels.
percentile_threshold = 5;

tbl_roa_heatmap_per_episode.img_roa_frequency = cellfun( ...
    @(x){x > prctile(x(:),100 - percentile_threshold)}, ...
    tbl_roa_heatmap_per_episode.img_roa_frequency);
%% Change the label quiet_awakening to quiet.
I = tbl_roa_heatmap_per_episode.state == 'quiet_awakening';
tbl_roa_heatmap_per_episode.state(I) = 'quiet';

%%
begonia.util.logging.vlog(1,'Table pre-processing finished.');
%%
tbl_all = {};

states_1 = {'quiet','whisking','nrem','is','rem'};
states_2 = states_1;

o = struct;
cnt = 1;
for i = 1:length(states_1)
    for j = 1:length(states_2)
        if i < j
            continue;
        end
        
        tbl_all{cnt} = alyssum_v2.plots_from_tables.roa_heatmap. ...
            roa_percent_heatmap_correlation_subfunc(tbl_roa_heatmap_per_episode,states_1{i},states_2{j});
        
        overlap = tbl_all{cnt}.overlap;
        N = length(overlap);
        mu = nanmean(overlap);
        sigma = nanstd(overlap)/sqrt(N);
        
        o(cnt).state_1 = states_1{i};
        o(cnt).state_2 = states_2{j};
        o(cnt).overlap_mean = mu;
        o(cnt).overlap_sem = sigma;
        o(cnt).samples = N;
        
        cnt = cnt + 1;
    end
end

tbl = struct2table(o,'AsArray',true);

tbl_all = cat(1,tbl_all{:});
%%
tbl_ts = alyssum_v2.tables.tseries_metadata(tm);
tbl_ids = alyssum_v2.tables.trial_ids(tm);
tbl_ts = innerjoin(tbl_ts,tbl_ids);
[~,I] = unique(tbl_ts.fov_id);
tbl_ts = tbl_ts(I,:);
tbl_ts.trial = [];

tbl_all = innerjoin(tbl_ts,tbl_all);

tbl_all.tr_uuid = [];
tbl_all.ts_uuid = [];
tbl_all.roa_ignore_mask_area = [];
tbl_all.img_dim = [];
tbl_all.fov_offset = [];
tbl_all.trial_duration = [];
end

