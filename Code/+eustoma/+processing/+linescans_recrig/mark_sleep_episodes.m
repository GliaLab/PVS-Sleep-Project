begonia.logging.set_level(1);

trials = eustoma.get_linescans_recrig();
trials = trials(trials.has_var('start_time'));

start_times = trials.load_var('start_time');
[~,I] = sort([start_times{:}],'descend');
trials = trials(I);
%%

actions = xylobium.dledit.Action.empty();

actions(end+1) = xylobium.dledit.Action('Mark Sleep', ...
    @(trial,~,~) open_gui(trial), ...
    false, false);

initial_vars = {};
initial_vars{end+1} = 'path';
initial_vars{end+1} = 'duration';
initial_vars{end+1} = 'trial_id';
initial_vars{end+1} = 'sleep_episodes';
initial_vars{end+1} = '!trial_type';

mod = eustoma.util.ReadStructMod('trial_id','trial_id');

xylobium.dledit.Editor(trials,actions,initial_vars,mod,false);

function open_gui(trial)

ephys = trial.load_var('ephys');

t = seconds(ephys.Time);
ecog = ephys.ecog;
emg = ephys.emg;

sleep_episodes = trial.load_var('sleep_episodes',[]);
sleep_episodes = yucca.processing.mark_sleep.mark_sleep(ecog,t,emg,t,sleep_episodes,{'NREM','IS','REM','Awakening'});

if isempty(sleep_episodes)
    begonia.logging.log(1,'No sleep episodes marked');
    trial.clear_var('sleep_episodes');
else
    begonia.logging.log(1,'Saving sleep episodes')
    sleep_episodes
    trial.save_var(sleep_episodes);
end

end