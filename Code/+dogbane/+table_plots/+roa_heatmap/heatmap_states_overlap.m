function tbl_overlap = heatmap_states_overlap(tbl_roa_heatmap_per_episode,tbl_ts_info)

%% Change the label quiet_awakening to quiet.
I = tbl_roa_heatmap_per_episode.state == 'quiet_awakening';
tbl_roa_heatmap_per_episode.state(I) = 'quiet';
I = tbl_roa_heatmap_per_episode.state == 'whisking_awakening';
tbl_roa_heatmap_per_episode.state(I) = 'whisking';

%%
tbl_ts_info = tbl_ts_info(:,{'genotype','mouse','experiment','fov_id'});
[~,I] = unique(tbl_ts_info.fov_id);
tbl_ts_info = tbl_ts_info(I,:);

[G,fov_id] = findgroups(tbl_roa_heatmap_per_episode.fov_id);

overlap_sleep = splitapply(@calculate_overlap_sleep, ...
    tbl_roa_heatmap_per_episode.img_roa_density, ...
    tbl_roa_heatmap_per_episode.state, ...
    tbl_roa_heatmap_per_episode.state_duration, ...
    G);

overlap_wake = splitapply(@calculate_overlap_wake, ...
    tbl_roa_heatmap_per_episode.img_roa_density, ...
    tbl_roa_heatmap_per_episode.state, ...
    tbl_roa_heatmap_per_episode.state_duration, ...
    G);

overlap_all = splitapply(@calculate_overlap_all, ...
    tbl_roa_heatmap_per_episode.img_roa_density, ...
    tbl_roa_heatmap_per_episode.state, ...
    tbl_roa_heatmap_per_episode.state_duration, ...
    G);

overlap_wake_sleep = splitapply(@calculate_overlap_wake_sleep, ...
    tbl_roa_heatmap_per_episode.img_roa_density, ...
    tbl_roa_heatmap_per_episode.state, ...
    tbl_roa_heatmap_per_episode.state_duration, ...
    G);

tbl_overlap = table(fov_id,overlap_wake,overlap_sleep,overlap_all,overlap_wake_sleep);

tbl_overlap = innerjoin(tbl_ts_info,tbl_overlap);
%%

[G,genotype] = findgroups(tbl_overlap.genotype);

overlap_wake_mean = splitapply(@nanmean,tbl_overlap.overlap_wake,G);
overlap_sleep_mean = splitapply(@nanmean,tbl_overlap.overlap_sleep,G);
overlap_all_mean = splitapply(@nanmean,tbl_overlap.overlap_all,G);
overlap_wake_sleep_mean = splitapply(@nanmean,tbl_overlap.overlap_wake_sleep,G);

overlap_wake_sem = splitapply(@(x)nanstd(x)/sqrt(sum(~isnan(x))),tbl_overlap.overlap_wake,G);
overlap_sleep_sem = splitapply(@(x)nanstd(x)/sqrt(sum(~isnan(x))),tbl_overlap.overlap_sleep,G);
overlap_all_sem = splitapply(@(x)nanstd(x)/sqrt(sum(~isnan(x))),tbl_overlap.overlap_all,G);
overlap_wake_sleep_sem = splitapply(@(x)nanstd(x)/sqrt(sum(~isnan(x))),tbl_overlap.overlap_wake_sleep,G);

overlap_wake_N = splitapply(@(x)sum(~isnan(x)),tbl_overlap.overlap_wake,G);
overlap_sleep_N = splitapply(@(x)sum(~isnan(x)),tbl_overlap.overlap_sleep,G);
overlap_all_N = splitapply(@(x)sum(~isnan(x)),tbl_overlap.overlap_all,G);
overlap_wake_sleep_N = splitapply(@(x)sum(~isnan(x)),tbl_overlap.overlap_wake_sleep,G);

table(genotype, ...
    overlap_wake_mean,overlap_wake_sem,overlap_wake_N, ...
    overlap_sleep_mean,overlap_sleep_sem,overlap_sleep_N, ...
    overlap_all_mean,overlap_all_sem,overlap_all_N, ...
    overlap_wake_sleep_mean,overlap_wake_sleep_sem,overlap_wake_sleep_N)

end

function overlap = calculate_overlap_sleep(heatmaps,states,durations)
comparison = {'nrem','is','rem'};
if ~all(ismember(comparison,states))
    overlap = nan;
    return;
end

dim = size(heatmaps{1});

img_intersect = true(dim);
img_union = false(dim);

for i = 1:length(comparison)
    I = ismember(states,comparison{i});
    heatmap = merge_heatmaps(heatmaps(I),durations(I));
    
    img_intersect = img_intersect & heatmap;
    img_union = img_union | heatmap;
end

if sum(img_union(:)) == 0
    overlap = 0;
else
    overlap = sum(img_intersect(:)) / sum(img_union(:));
end

end

function overlap = calculate_overlap_wake(heatmaps,states,durations)
comparison = {'locomotion','whisking','quiet'};
if ~all(ismember(comparison,states))
    overlap = nan;
    return;
end

dim = size(heatmaps{1});

img_intersect = true(dim);
img_union = false(dim);

for i = 1:length(comparison)
    I = ismember(states,comparison{i});
    heatmap = merge_heatmaps(heatmaps(I),durations(I));
    
    img_intersect = img_intersect & heatmap;
    img_union = img_union | heatmap;
end

if sum(img_union(:)) == 0
    overlap = 0;
else
    overlap = sum(img_intersect(:)) / sum(img_union(:));
end

end

function overlap = calculate_overlap_all(heatmaps,states,durations)
comparison = {'whisking','quiet','nrem','is','rem'};
if ~all(ismember(comparison,states))
    overlap = nan;
    return;
end

dim = size(heatmaps{1});

img_intersect = true(dim);
img_union = false(dim);

for i = 1:length(comparison)
    I = ismember(states,comparison{i});
    heatmap = merge_heatmaps(heatmaps(I),durations(I));
    
    img_intersect = img_intersect & heatmap;
    img_union = img_union | heatmap;
end

if sum(img_union(:)) == 0
    overlap = 0;
else
    overlap = sum(img_intersect(:)) / sum(img_union(:));
end

end

function overlap = calculate_overlap_wake_sleep(heatmaps,states,durations)
states = mergecats(states,{'locomotion','whisking','quiet'},'wake');
states = mergecats(states,{'nrem','is','rem'},'sleep');

comparison = {'wake','sleep'};
if ~all(ismember(comparison,states))
    overlap = nan;
    return;
end

dim = size(heatmaps{1});

img_intersect = true(dim);
img_union = false(dim);

for i = 1:length(comparison)
    I = ismember(states,comparison{i});
    heatmap = merge_heatmaps(heatmaps(I),durations(I));
    
    img_intersect = img_intersect & heatmap;
    img_union = img_union | heatmap;
end

if sum(img_union(:)) == 0
    overlap = 0;
else
    overlap = sum(img_intersect(:)) / sum(img_union(:));
end

end

function heatmap = merge_heatmaps(heatmaps,durations)
percentile_threshold = 5;

durations = reshape(durations,1,1,[]);
heatmap = cat(3,heatmaps{:});
heatmap = sum(heatmap .* durations,3) / sum(durations);
heatmap = heatmap > prctile(heatmap(:),100 - percentile_threshold);
end





