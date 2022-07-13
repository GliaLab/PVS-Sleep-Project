function load_sleep(trials)

trials = [trials.rec_rig_trial];
% begonia.util.logging.vlog(1,'Checking that trial IDs are set');
% assert(~any(~trials.has_var('trial')),'The trial ID must be loaded before sleep can be loaded.')

% Only pick out the trials which have the trial ID set.
trials = trials(trials.has_var('trial'));
assert(~isempty(trials));
%% Load sleep from XL sheets
% For each experiment pick out the trials and send to load_sleep_stages_from_xlsx
paths = {trials.path};
exp = begonia.path.up_a_lvl(paths);

[c,ia,ic] = unique(exp);
for i = 1:length(c)
    experiment_folder = exp{ia(i)};
    trials_sub = trials(ic==i);
    dogbane.util.load_sleep_stages_from_xlsx(trials_sub,experiment_folder);
end

end

