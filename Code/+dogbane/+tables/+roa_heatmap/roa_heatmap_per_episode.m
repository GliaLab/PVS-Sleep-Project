function tbl = roa_heatmap_per_episode(tm)

trials = tm.get_trials();
%% Make table of heatmaps from each episode.
max_offset = 10;

cnt = 1;
cnt_skipped = 0;

tbl = [];

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,'%d/%d',i,length(trials));
    ts = trials(i).tseries;
    tr = trials(i).rec_rig_trial;
    
    if isempty(ts)
        continue;
    end
    
    fov_id      = ts.load_var('fov_id');
    fov_offset  = ts.load_var('fov_offset');

    genotype    = tr.load_var('genotype');
    mouse       = tr.load_var('mouse');
    experiment  = tr.load_var('experiment');
    trial_id    = tr.load_var('trial');
    
    if max(fov_offset) > max_offset
        cnt_skipped = cnt_skipped + 1;
        continue;
    end
    
    %%
    tbl_heatmaps = ts.load_var('roa_heatmap_per_episode');
    tbl_heatmaps.img_roa_point = [];
    
    % Removed undefined
    tbl_heatmaps(tbl_heatmaps.state == 'undefined',:) = [];
    
    if isempty(tbl_heatmaps)
        begonia.util.logging.vlog(1,'Skipping trial because no episodes were defined.');
        continue;
    end
    
    % Change to single to make it a bit faster. 
    tbl_heatmaps.img_roa_frequency = cellfun( ...
        @(img) {single(img)}, ...
        tbl_heatmaps.img_roa_frequency);
    tbl_heatmaps.img_roa_density = cellfun( ...
        @(img) {single(img)}, ...
        tbl_heatmaps.img_roa_density);
    
    % Align
    tbl_heatmaps.img_roa_frequency = cellfun( ...
        @(img) {circshift(img,fov_offset)}, ...
        tbl_heatmaps.img_roa_frequency);
    tbl_heatmaps.img_roa_density = cellfun( ...
        @(img) {circshift(img,fov_offset)}, ...
        tbl_heatmaps.img_roa_density);
    
    % Crop to ensure there are no artifacts from the alignment. 
    tbl_heatmaps.img_roa_frequency = cellfun( ...
        @(img) {img(max_offset:end-max_offset,max_offset:end-max_offset)}, ...
        tbl_heatmaps.img_roa_frequency); 
    tbl_heatmaps.img_roa_density = cellfun( ...
        @(img) {img(max_offset:end-max_offset,max_offset:end-max_offset)}, ...
        tbl_heatmaps.img_roa_density);
    
    % Load roa ignore mask and the average image.
    roa_ignore_mask = ts.load_var('roa_ignore_mask');
    avg_img = ts.get_avg_img(1,1);
    
    % Align and crop
    roa_ignore_mask = circshift(roa_ignore_mask,fov_offset);
    roa_ignore_mask = roa_ignore_mask(max_offset:end-max_offset,max_offset:end-max_offset);
    
    avg_img = circshift(avg_img,fov_offset);
    avg_img = avg_img(max_offset:end-max_offset,max_offset:end-max_offset);
    avg_img = single(avg_img);
    %% Add data
    tbl_heatmaps.fov_id = repmat(fov_id,height(tbl_heatmaps),1);
    tbl_heatmaps.genotype = repmat({genotype},height(tbl_heatmaps),1);
    tbl_heatmaps.mouse = repmat({mouse},height(tbl_heatmaps),1);
    tbl_heatmaps.experiment = repmat({experiment},height(tbl_heatmaps),1);
    tbl_heatmaps.trial_id = repmat({trial_id},height(tbl_heatmaps),1);
    tbl_heatmaps.avg_img = repmat({avg_img},height(tbl_heatmaps),1);
    tbl_heatmaps.roa_ignore_mask = repmat({roa_ignore_mask},height(tbl_heatmaps),1);
    
    %% Aggregate
    if isempty(tbl)
        tbl = tbl_heatmaps;
    else
        tbl = cat(1,tbl,tbl_heatmaps);
    end
    
    cnt = cnt + 1;
end

tbl.genotype = categorical(tbl.genotype);
tbl.mouse = categorical(tbl.mouse);
tbl.experiment = categorical(tbl.experiment);
tbl.trial_id = categorical(tbl.trial_id);

begonia.util.logging.vlog(1,['Skipped ',num2str(cnt_skipped),' trials as FOV offset was too large.']);

end

