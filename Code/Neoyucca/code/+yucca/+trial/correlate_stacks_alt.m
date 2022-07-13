function [cor_stacks,cor_trials] = correlate_stacks_alt(varargin)
p = inputParser;
p.addRequired('stacks',...
    @(x) validateattributes(x,{'begonia.stack.Stack', 'begonia.data_management.DataLocation', 'Ephys', 'begonia.scantype.prairie.PrairieOutput'},{'nonempty'}));
p.addRequired('trials',...
    @(x) validateattributes(x,{'yucca.trial.Trial'},{'nonempty'}));
p.addParameter('time_window',seconds(30),...
    @(x) validateattributes(x,{'duration'},{'nonempty'}));
p.addParameter('lag',seconds(0),...
    @(x) validateattributes(x,{'duration'},{'nonempty'}));
p.addParameter('force_closest',false,...
    @(x) validateattributes(x,{'logical'},{}));
p.addParameter('do_correct',false,...
    @(x) validateattributes(x,{'logical'},{}));
% p.addParameter('method', 'leeway', ...
%     @(x) validatestring(x,{'leeway'}));
p.parse(varargin{:});

stacks = p.Results.stacks;
trials = p.Results.trials;
time_window = p.Results.time_window;
lag = p.Results.lag;
force_closest = p.Results.force_closest;
do_correct = p.Results.do_correct;
%% Props
for i = 1:length(trials)
    if ~isprop(trials(i), 'associated_stacks')
        addprop(trials(i), 'associated_stacks');
    end
    trials(i).associated_stacks = [];
end

for i = 1:length(stacks)
    if ~isprop(stacks(i), 'associated_trials')
        addprop(stacks(i), 'associated_trials');
    end
    stacks(i).associated_trials = [];
end

%% Create time array of the stacks and trials.
% stack_times = datetime.empty(0);
% for i = 1:length(stacks)
%     stack_times(i) = datetime(stacks(i).record_date, 'InputFormat','MM/dd/uuuu hh:mm:ss aa');
% end
% stack_times = stack_times - lag;

% trial_times = [trials.DateRecorded];
try
    stack_times = [stacks.start_time];
catch
    stack_times = arrayfun(@(x) x.start_time_abs, stacks);
end
trial_times = [trials.start_time];

trial_times.Format = 'dd-MMM-uuuu HH:mm:ss.SSS';
stack_times.Format = 'dd-MMM-uuuu HH:mm:ss.SSS';

%% Correlate trials and stacks.
offsets = duration.empty(0);
cor_trials = [];
cor_stacks = [];


function connect(trial,stack,dt)
    assert(contains(class(dt), {'duration', 'calendarDuration'}))
    stack.associated_trials = trial;
    trial.associated_stacks = stack;
    if do_correct == true
        trial.time_correction = dt;
    end
    offsets = cat(2,offsets,dt);
    cor_trials = cat(2,cor_trials,trial);
    cor_stacks = cat(2,cor_stacks,stack);
end

for i = 1:length(trial_times)
    if force_closest
        I = ones(1,length(stack_times),'logical');
    else
        % Get the indices of the stacks within the time window.
        val_1 = stack_times > (trial_times(i) - time_window);
        val_2 = stack_times < (trial_times(i) + time_window);
        I = val_1 & val_2;
    end
    
    % Get the index of the stack with the closest timing of the stacks that
    % have timings within the window.
    [~,I_2] = min(abs(stack_times(I) - trial_times(i)));
    
    if isempty(I_2); continue; end
    
    closest_stack = stacks(I);
    closest_stack = closest_stack(I_2);
    
    closest_stack_time = stack_times(I);
    closest_stack_time = closest_stack_time(I_2) - trial_times(i);
    
    connect(trials(i),closest_stack,closest_stack_time);
end



global BEGONIA_VERBOSE
if BEGONIA_VERBOSE >= 1
    fprintf('Number of correlated trials = %d\n',length(offsets));
    fprintf('Mean offset between stacks and trials = %.2f secs \n',seconds(mean(offsets)));
    fprintf('Std offset between stacks and trials = %.2f secs \n',seconds(std(offsets)));
    fprintf('Max offset between stacks and trials = %.2f secs \n',seconds(max(offsets)));
    fprintf('Min offset between stacks and trials = %.2f secs \n',seconds(min(offsets)));
end




end

