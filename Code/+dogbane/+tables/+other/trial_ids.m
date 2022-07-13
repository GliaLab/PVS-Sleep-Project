function tbl = trial_ids(tm)
%% Get trial data from rec_rig_trials
trials = tm.get_trials();
rr_trials = [trials.rec_rig_trial];

vars2table = memoize(@begonia.data_management.vars2table);
% vars2table = @begonia.data_management.vars2table;

tbl = vars2table(rr_trials,{'genotype','mouse','experiment','trial'});

tbl.genotype = categorical(tbl.genotype);
tbl.mouse = categorical(tbl.mouse);
tbl.experiment = categorical(tbl.experiment);
tbl.trial = categorical(tbl.trial);

tbl.tr_uuid = tbl.uuid;
tbl.uuid = [];

%% Get trial and ts uuid data. 
trials = tm.get_trials();
tr_uuid = categorical(repmat({''},length(trials),1));
ts_uuid = categorical(repmat({''},length(trials),1));
for i = 1:length(trials)
    tr_uuid(i) = trials(i).rec_rig_trial.uuid;
    ts_uuid(i) = trials(i).tseries.uuid;
end
tbl_tmp = table(tr_uuid,ts_uuid);

tbl = innerjoin(tbl,tbl_tmp);
%%
[~,I] = sort(tbl.trial);
tbl = tbl(I,:);
end

