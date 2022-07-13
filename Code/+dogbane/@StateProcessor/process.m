function [states,states_fs] = process(self, ...
    duration, ...
    manual_sleep_stages,manual_sleep_stages_dt, ...
    camera_wheel,camera_whisker,camera_dt)
%% Reshape
manual_sleep_stages = reshape(manual_sleep_stages,1,[]);
camera_wheel = reshape(camera_wheel,1,[]);
camera_whisker = reshape(camera_whisker,1,[]);
%% Define stuff
states_fs = self.fs;
states_dt = 1/states_fs;
states_t = 0:states_dt:duration;

N = length(states_t);

%% Load all state vectors as logicals. 
if self.locomotion || self.whisking || self.twitching
    if isnan(camera_dt)
        states = categorical.empty;
        states_fs = nan;
        return
    end
    camera_t = 0:length(camera_wheel)-1;
    camera_t = camera_t*camera_dt;
    
    camera_whisker = resample(camera_whisker,camera_t,states_fs);
    
    camera_wheel = resample(camera_wheel,camera_t,states_fs);
    
    % Extract states in logical vectors of equal length.
    [locomotion,whisking] = dogbane.util.state_from_camera_trace( ...
        camera_whisker,camera_wheel,states_dt);
    
    if length(locomotion) > N
        locomotion = locomotion(1:N);
        whisking = whisking(1:N);
    end
    
    if length(locomotion) < N
        locomotion(end+1:N) = false;
        whisking(end+1:N) = false;
    end
else
    locomotion = false(1,N);
    whisking = false(1,N);
end

if self.wake_and_sleep || self.manual_sleep || self.awakening || self.wake_and_sleep_is_merged_states
    if isnan(manual_sleep_stages_dt)
        states = categorical.empty;
        states_fs = nan;
        return
    end
    
    manual_sleep_stages_t = 0:length(manual_sleep_stages)-1;
    manual_sleep_stages_t = manual_sleep_stages_t*manual_sleep_stages_dt;
    
    % Get the manual sleep stages
    rem         = manual_sleep_stages == 'rem';
    nrem        = manual_sleep_stages == 'nrem';
    is          = manual_sleep_stages == 'pre_rem';
    wake        = manual_sleep_stages == 'pre_sleep';
    
    % Awakenings can be tagged as an awakening from either rem, nrem or is.
    % Each of these awakenings have their own name in the sleep_stages
    % array. These are : awakenings:rem, awakenings:nrem,
    % awakenings:pre_rem or just awakenings. 
    % Here awakenings from the different states are marked both as the
    % state and as awakening resulting in a state that is the combination
    % of both. E.g. awakenings:rem becomes rem AND awakening -> rem:awakening.
    if self.differentiate_awakening && self.awakening
        rem(manual_sleep_stages == 'awakenings:rem') = true;
        nrem(manual_sleep_stages == 'awakenings:nrem') = true;
        is(manual_sleep_stages == 'awakenings:pre_rem') = true;
    end
    manual_sleep_stages = mergecats(manual_sleep_stages,{'awakenings:rem','awakenings:nrem','awakenings:pre_rem'},'awakenings');
    awakening   = manual_sleep_stages == 'awakenings';
    
    % Resample to the sampling frequency and length of 'states_t'
    rem         = begonia.util.align_indices(states_t,manual_sleep_stages_t,rem);
    nrem        = begonia.util.align_indices(states_t,manual_sleep_stages_t,nrem);
    is          = begonia.util.align_indices(states_t,manual_sleep_stages_t,is);
    awakening   = begonia.util.align_indices(states_t,manual_sleep_stages_t,awakening);
    wake        = begonia.util.align_indices(states_t,manual_sleep_stages_t,wake);
    
    % If there is any wakefulness, the whole trial should be wakefulness.
    if any(wake); wake(:) = true; end
    
    sleep   = ~wake;
else
    rem         = false(1,N);
    nrem        = false(1,N);
    is          = false(1,N);
    wake        = false(1,N);
    awakening   = false(1,N);
    sleep       = false(1,N);
end

%% Locomotion & whisking & twitching

if self.locomotion || self.whisking || self.twitching
    
    % Disable locomotion during sleep.
    % The wheel has been locked in some sleep trials and locomotion during
    % the sleep trials shouldnt really happen anyway. If the mouse wakes up
    % it will be detected as whisking.
    locomotion(sleep) = false;

    % Padding
    if self.whisking_padding_after ~= 0
        whisking = begonia.util.dilate_logical( ...
            whisking, ...
            round(self.whisking_padding_after/states_dt), ...
            'right');
    end
    if self.whisking_padding_before ~= 0
        whisking = begonia.util.dilate_logical( ...
            whisking, ...
            round(self.whisking_padding_before/states_dt), ...
            'left');
    end
    if self.locomotion_padding_after ~= 0
        locomotion = begonia.util.dilate_logical( ...
            locomotion, ...
            round(self.locomotion_padding_after/states_dt), ...
            'right');
    end
    if self.locomotion_padding_before ~= 0
        locomotion = begonia.util.dilate_logical( ...
            locomotion, ...
            round(self.locomotion_padding_before/states_dt), ...
            'left');
    end
    
    locomotion = begonia.util.erode_logical(locomotion, round(2.5/states_dt));
    locomotion = begonia.util.dilate_logical(locomotion, round(2.5/states_dt));
    
    % Locomotion overrides whisking (if we are using locomotion).
    if self.locomotion
        whisking(locomotion) = false;
    end
    
    % Define twitching
    twitching = whisking;
    
    % Remove episodes shorter than the twitch duration, these episodes
    % are defined as twitching. 
    whisking = begonia.util.erode_logical(whisking, round(self.twitching_max_duration/states_dt/2));
    whisking = begonia.util.dilate_logical(whisking, round(self.twitching_max_duration/states_dt/2));
    
    % Define twitching as whisking episodes that are shorter than twitch_duration.
    twitching(whisking) = false;
else
    twitching = false(1,N);
end

if ~self.whisking
    whisking(:) = false;
end

if ~self.locomotion
    locomotion(:) = false;
end

if ~self.twitching
    twitching(:) = false;
end
    
%% motion
if self.motion
    motion = locomotion | whisking;
    locomotion(:) = false;
    whisking(:) = false;
else
    motion = false(1,N);
end

%% quiet wakefulness
if self.quiet_wakefulness
    quiet_wakefulness = wake;
    
    % The active states overrides quiet_wakefulness.
    quiet_wakefulness(locomotion | whisking | motion) = false;
    
    if self.twitching
        quiet_wakefulness(twitching) = false;
    end
else
    quiet_wakefulness = false(1,N);
end

if self.quiet_wakefulness_padding_after ~= 0
    quiet_wakefulness = begonia.util.dilate_logical( ...
        quiet_wakefulness, ...
        round(self.quiet_wakefulness_padding_after/states_dt), ...
        'right');
end

if self.quiet_wakefulness_padding_before ~= 0
    quiet_wakefulness = begonia.util.dilate_logical( ...
        quiet_wakefulness, ...
        round(self.quiet_wakefulness_padding_before/states_dt), ...
        'left');
end

if self.quiet_wakefulness
    % Only include quiet_wakefulness episodes longer than a set duration.
    quiet_wakefulness = begonia.util.erode_logical(quiet_wakefulness, round(self.quiet_wakefulness_minimum_duration/2*states_fs));
    quiet_wakefulness = begonia.util.dilate_logical(quiet_wakefulness, round(self.quiet_wakefulness_minimum_duration/2*states_fs));
end

%% All active stages
if self.ignore_activity_during_sleep
    whisking(sleep) = false;
    locomotion(sleep) = false;
    motion(sleep) = false;
    twitching(sleep) = false;
end

% % Only include the inital period of locomotion and whisking
% if self.locomotion
%     n = states_fs*10; % 10 seconds
%     vec = begonia.util.erode_logical(locomotion,n,'left');
%     locomotion = xor(locomotion,vec);
% end
% if self.whisking
%     n = states_fs*10;
%     vec = begonia.util.erode_logical(whisking,n,'left');
%     whisking = xor(whisking,vec);
% end

%% rem/nrem/is
if self.manual_sleep
%     % make the whisking periods in nrem/rem/is into twitches
%     if self.twitching
%         twitching(is & whisking) = true;
%         twitching(rem & whisking) = true;
%         twitching(nrem & whisking) = true;
%     end
    whisking(is) = false;
    whisking(rem) = false;
    whisking(nrem) = false;
else
    rem(:) = false;
    nrem(:) = false;
    is(:) = false;
end

if self.manual_sleep_padding_after ~= 0
    rem = begonia.util.dilate_logical( ...
        rem, ...
        round(self.manual_sleep_padding_after/states_dt), ...
        'right');
    nrem = begonia.util.dilate_logical( ...
        nrem, ...
        round(self.manual_sleep_padding_after/states_dt), ...
        'right');
    is = begonia.util.dilate_logical( ...
        is, ...
        round(self.manual_sleep_padding_after/states_dt), ...
        'right');
end

if self.manual_sleep_padding_before ~= 0
    rem = begonia.util.dilate_logical( ...
        rem, ...
        round(self.manual_sleep_padding_before/states_dt), ...
        'left');
    nrem = begonia.util.dilate_logical( ...
        nrem, ...
        round(self.manual_sleep_padding_before/states_dt), ...
        'left');
    is = begonia.util.dilate_logical( ...
        is, ...
        round(self.manual_sleep_padding_before/states_dt), ...
        'left');
end
%% awakening
if self.awakening
    % ignore twitching and whisking if awakening
    twitching(awakening) = false;
    whisking(awakening) = false;
else
    awakening(:) = false;
end

%% general (undefined) sleep and wakefulness
if ~self.wake_and_sleep
    wake(:) = false;
    sleep(:) = false;
end

if self.wake_and_sleep_is_merged_states
    wake = motion | whisking | twitching | locomotion | quiet_wakefulness | wake;
    sleep = nrem | rem | is | sleep;

    motion(:) = false;
    whisking(:) = false;
    twitching(:) = false;
    locomotion(:) = false;
    quiet_wakefulness(:) = false;
    nrem(:) = false;
    rem(:) = false;
    is(:) = false;
else
    wake(motion|whisking|twitching|locomotion|quiet_wakefulness) = false;
    sleep(nrem|rem|is|awakening) = false;
end

%% Assign to states_mat, a binary matrix. 
N_STATES = dogbane.constants.N_STATES;

states_mat = false(N_STATES,N);
states_mat(dogbane.constants.SLEEP,:) = sleep;
states_mat(dogbane.constants.REM,:) = rem;
states_mat(dogbane.constants.NREM,:) = nrem;
states_mat(dogbane.constants.IS,:) = is;
states_mat(dogbane.constants.AWAKENING,:) = awakening;

states_mat(dogbane.constants.WAKE,:) = wake;
states_mat(dogbane.constants.WHISKING,:) = whisking;
states_mat(dogbane.constants.LOCOMOTION,:) = locomotion;
states_mat(dogbane.constants.MOTION,:) = motion;
states_mat(dogbane.constants.QUIET,:) = quiet_wakefulness;
states_mat(dogbane.constants.TWITCHING,:) = twitching;

%% Ignore inital part of all recordings. 
states_mat(:,1:ceil(states_fs*10)) = false;

%%
states = states_mat2states(self,states_mat);
end

