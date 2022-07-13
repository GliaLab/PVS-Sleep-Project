function tbl = tseries_metadata(tm)

tr = tm.get_trials();
ts = [tr.tseries];

ts_uuid = categorical({ts.uuid}');
optical_zoom = [ts.optical_zoom]';
dx = [ts.dx]';
dt = [ts.dt]';
dx_squared = dx.*dx;
trial_duration = seconds([ts.duration])';

roa_ignore_mask_area = ts.load_var('roa_ignore_mask_area',nan);
roa_ignore_mask_area = cell2mat(roa_ignore_mask_area)';

fov_id = ts.load_var('fov_id',nan);
fov_id = cell2mat(fov_id)';

fov_offset = ts.load_var('fov_offset',[nan,nan]);
fov_offset = cell2mat(fov_offset');

img_dim = zeros(length(ts),2);
for i = 1:length(ts)
    img_dim(i,:) = size(ts(i).get_avg_img(1,1));
end

tbl = table(ts_uuid,optical_zoom,dx,dt,dx_squared,roa_ignore_mask_area,img_dim,fov_id,fov_offset,trial_duration);

tbl_ids = dogbane.tables.other.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);

end

