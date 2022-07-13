function self = reset(self)

init(self);

self.expected_outputs = {};

self.preset_ = '';

self.wake_and_sleep_ = false;
self.wake_and_sleep_is_merged_states_ = false;

self.motion_ = false;

self.locomotion_ = false;
self.locomotion_padding_before_ = 0;
self.locomotion_padding_after_ = 0;

self.whisking_ = false;
self.whisking_padding_before_ = 0;
self.whisking_padding_after_ = 0;

self.twitching_ = false;
self.twitching_max_duration_ = 3;

self.quiet_wakefulness_ = 0;
self.quiet_wakefulness_minimum_duration_ = 5;
self.quiet_wakefulness_padding_before_ = 0;
self.quiet_wakefulness_padding_after_ = 0;

self.ignore_activity_during_sleep_ = false;

self.manual_sleep_ = false;
self.manual_sleep_padding_before_ = 0;
self.manual_sleep_padding_after_ = 0;

self.awakening_ = false;
self.differentiate_awakening_ = false;
end