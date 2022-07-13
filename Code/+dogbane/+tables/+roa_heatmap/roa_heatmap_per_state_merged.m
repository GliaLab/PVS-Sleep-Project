function tbl = roa_heatmap_per_state_merged(tm,num_heatmaps_per_state)

tbl = dogbane.tables.roa_heatmap.roa_heatmap_per_episode(tm);

%% Identify which episodes should be merged
[G,fov_id,state] = findgroups(tbl.fov_id,tbl.state);
merge_grp = zeros(length(G),1);
for i = 1:length(fov_id)
    I = G == i;
    durs = tbl.state_duration(I);
    if length(durs) < num_heatmaps_per_state
        continue;
    end
    merge_grp(I) = dogbane.util.divide_weights(durs,num_heatmaps_per_state)';
end

tbl.merge_grp = merge_grp;
%% Merge states
begonia.util.logging.vlog(1,'Merging episodes')
[G,fov_id,state,merge_grp] = findgroups(tbl.fov_id,tbl.state,tbl.merge_grp);

state_duration = splitapply(@sum,tbl.state_duration,G);
img_roa_frequency = splitapply(@merge_heatmaps,tbl.img_roa_frequency,tbl.state_duration,G);
genotype = splitapply(@(x)x(1),tbl.genotype,G);
mouse = splitapply(@(x)x(1),tbl.mouse,G);
experiment = splitapply(@(x)x(1),tbl.experiment,G);
trial_id = splitapply(@(x)x(1),tbl.trial_id,G);

tbl = table(genotype,mouse,fov_id,state,merge_grp,state_duration,img_roa_frequency);

end

function img = merge_heatmaps(imgs,durs)
imgs = cat(3,imgs{:});
durs = reshape(durs,1,1,[]);
img = sum(imgs .* durs,3) / sum(durs);
img = {img};
end

