function apply_preset(self,preset)
reset(self);

switch preset
    case 'sleep_and_activity'
        self.preset_ = preset;
        self.locomotion_ = true;
        self.whisking_ = true;
        self.quiet_wakefulness_padding_after_ = -3;
        self.quiet_wakefulness_ = true;
        self.manual_sleep_ = true;
        self.ignore_activity_during_sleep_ = true;
    case 'sleep_and_wake'
        self.preset_ = preset;
        self.wake_and_sleep_is_merged_states_ = true;
        self.locomotion_ = true;
        self.whisking_ = true;
        self.quiet_wakefulness_ = true;
        self.manual_sleep_ = true;
        self.ignore_activity_during_sleep_ = true;
    case 'manual_scoring'
        self.preset_ = preset;
        self.manual_sleep_ = true;
        self.awakening_ = true;
    otherwise
        error('Undefined preset ''%s''.',preset);
end

end

