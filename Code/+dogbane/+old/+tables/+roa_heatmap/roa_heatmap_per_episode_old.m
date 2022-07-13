function tbl = roa_heatmap_per_episode(tm)
tbl = alyssum_v2.tables.variable_to_table_tseries(tm,'roa_heatmap_per_episode',true);

tbl(tbl.state == 'undefined',:) = [];

tbl_ts = alyssum_v2.tables.tseries_metadata(tm);

tbl = innerjoin(tbl,tbl_ts);

begonia.util.logging.vlog(1,'Making images into single')
tbl.img_roa_frequency = cellfun(@(x){single(x)},tbl.img_roa_frequency);
tbl.img_roa_density = cellfun(@(x){single(x)},tbl.img_roa_density);
% tbl.img_roa_point = cellfun(@(x){single(x)},tbl.img_roa_point);
tbl.img_roa_point = [];

begonia.util.logging.vlog(1,'Gathering average images')
tbl_img_avg = alyssum_v2.tables.images_and_trials(tm);
tbl_img_avg = tbl_img_avg(:,{'trial','avg_img'});
tbl_img_avg.avg_img = cellfun(@(x){single(x)},tbl_img_avg.avg_img);

tbl = innerjoin(tbl,tbl_img_avg);
end

