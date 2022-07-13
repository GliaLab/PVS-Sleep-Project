function tbl = detection_thresholds(tm)
trials = tm.get_trials();

o = struct;
cnt = 1;

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,'%d/%d',i,length(trials));
    
    ts = trials(i).tseries;
    tr = trials(i).rec_rig_trial;
    
    if isempty(ts)
        continue;
    end
    
    % ROA ignore mask.
    if ts.has_var('roa_ignore_mask')
        roa_ignore_mask = ts.load_var('roa_ignore_mask');
    else
        mat = ts.get_mat(1,1);
        dim = size(mat);
        roa_ignore_mask = false(dim(1:2));
    end
    edge_ignore_width = 15;
    roa_ignore_mask(1:edge_ignore_width,:) = true;
    roa_ignore_mask(end-edge_ignore_width:end,:) = true;
    roa_ignore_mask(:,1:edge_ignore_width) = true;
    roa_ignore_mask(:,end-edge_ignore_width:end) = true;
    % Flips it. Result is true where ROAs are allowed.
    roa_ignore_mask = ~roa_ignore_mask;
    
    img_sigma = ts.load_var('highpass_img_sigma');
    
    img_sigma(~roa_ignore_mask) = nan;
    
    o(cnt).ts_uuid = ts.uuid;
    o(cnt).sigma = nanmean(img_sigma(:));
    
    state_episodes = tr.load_var('state_episodes');
    
    if any(ismember(state_episodes.State,{'rem','nrem','is'}))
        o(cnt).sleep_trial = 'sleep';
    elseif any(ismember(state_episodes.State,{'locomotion','quiet','whisking'}))
        o(cnt).sleep_trial = 'awake';
    else
        o(cnt).sleep_trial = 'undefined';
    end
    
    cnt = cnt + 1;
end

tbl = struct2table(o);
tbl.ts_uuid = categorical(tbl.ts_uuid);
tbl.sleep_trial = categorical(tbl.sleep_trial);
%%
tbl_ids = dogbane.tables.other.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);

tbl_ts_data = dogbane.tables.other.tseries_metadata(tm);
tbl_ts_data = tbl_ts_data(:,{'ts_uuid','dx','dx_squared','optical_zoom'});
tbl = innerjoin(tbl,tbl_ts_data);

end

