begonia.logging.set_level(1);

trials = eustoma.get_endfoot_recrigs();

% begonia.logging.log(1,'Filtering %d trials',length(trials));
trials = trials(trials.has_var('ephys_norm'));
% begonia.logging.log(1,'%d trials left',length(trials));

%%
actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark Episodes', ...
    @(trial,~,~) open_gui(trial), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = 'sleep_episodes';

xylobium.dledit.Editor(trials,actions,initial_vars,[],false);

function open_gui(trial)

ephys = trial.load_var('ephys_norm');

t = seconds(ephys.Time);
ecog = ephys.ecog;
emg = ephys.emg;

sleep_episodes = trial.load_var('sleep_episodes',[]);
sleep_episodes = yucca.processing.mark_sleep.mark_sleep(ecog,t,emg,t,sleep_episodes);

if isempty(sleep_episodes)
    begonia.logging.log(1,'No sleep episodes marked');
    trial.clear_var('sleep_episodes');
else
    begonia.logging.log(1,'Saving sleep episodes')
    sleep_episodes
    trial.save_var(sleep_episodes);
end

end
