function tbl = rois(tm)

trials = tm.get_trials();

tbls = {};
begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,'%6.2f%%',i/length(trials)*100);
    ts = trials(i).tseries;
    if isempty(ts)
        continue;
    end
    
    roi_array = ts.load_var('roi_array',[]);
    if isempty(roi_array)
        continue;
    end
    
    trial_id = trials(i).rec_rig_trial.load_var('trial');
    
    roi_array = struct2table(roi_array,'AsArray',true);
    roi_array = roi_array(:,{'group','channel','id','area'});
    roi_array.trial = repmat({trial_id},height(roi_array),1);
    
    tbls{end+1} = roi_array;
end

tbl = cat(1,tbls{:});
tbl.trial = categorical(tbl.trial);
tbl.roi_group = categorical(tbl.group);
tbl.group = [];

tbl.roi_id = categorical(tbl.id);
tbl.id = [];

tbl_ids = dogbane.tables.other.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);

end

