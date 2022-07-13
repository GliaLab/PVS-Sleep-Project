function tbl = metadata(trials)

o = struct;

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,sprintf('metadata %d/%d',i,length(trials)));
    if isempty(trials(i).tseries)
        o(i).ts_name = '';
        o(i).fov_id_count  = nan;
    else
        o(i).ts_name = trials(i).tseries.name;
        o(i).fov_id_count = trials(i).tseries.load_var('fov_id_count',nan);
    end
    
    if isempty(trials(i).rec_rig_trial)
        o(i).genotype           = '';
        o(i).mouse              = '';
        o(i).experiment         = '';
        o(i).trial              = '';
    else
        o(i).genotype           = trials(i).rec_rig_trial.load_var('genotype','');
        o(i).mouse              = trials(i).rec_rig_trial.load_var('mouse','');
        o(i).experiment         = trials(i).rec_rig_trial.load_var('experiment','');
        o(i).trial              = trials(i).rec_rig_trial.load_var('trial','');
    end
end

tbl = struct2table(o,'AsArray',true);
tbl.ignored_roa_trial = ismember(tbl.trial,dogbane.constants.excluded_roa_trials);
tbl.ignored_trial = ismember(tbl.ts_name,dogbane.constants.excluded_tseries);
tbl.trial = [];
tbl.ts_name = [];
end

