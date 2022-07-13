classdef StateProcessor < handle
    properties
        preset = '' 
        
        wake_and_sleep
        wake_and_sleep_is_merged_states
        
        motion
        
        locomotion
        locomotion_padding_before
        locomotion_padding_after
        
        whisking
        whisking_padding_before
        whisking_padding_after
        
        twitching
        twitching_max_duration

        quiet_wakefulness
        quiet_wakefulness_minimum_duration
        quiet_wakefulness_padding_before
        quiet_wakefulness_padding_after
        
        ignore_activity_during_sleep
        
        manual_sleep
        manual_sleep_padding_before
        manual_sleep_padding_after
        
        awakening
        differentiate_awakening
        
        expected_outputs
        
        fs = 30;
    end
    
    properties (Access = private)
        val_set
        cat_set
        
        preset_ = '' 
        
        wake_and_sleep_
        wake_and_sleep_is_merged_states_
        
        motion_
        
        locomotion_
        locomotion_padding_before_
        locomotion_padding_after_
        
        whisking_
        whisking_padding_before_
        whisking_padding_after_
        
        twitching_
        twitching_max_duration_

        quiet_wakefulness_
        quiet_wakefulness_minimum_duration_
        quiet_wakefulness_padding_before_
        quiet_wakefulness_padding_after_
        
        ignore_activity_during_sleep_
        
        manual_sleep_
        manual_sleep_padding_before_
        manual_sleep_padding_after_
        
        awakening_
        differentiate_awakening_
    end
    
    methods
        
        function self = StateProcessor()
            apply_preset(self,'manual_scoring');
        end
        
        %% Setters and getters
        function val = get.expected_outputs(self)
            %% Adding states
            val = {};
            
            if self.wake_and_sleep
                val{end+1} = 'sleep';
                val{end+1} = 'wake';
                
                if self.motion
                    val{end+1} = 'sleep:motion';
                else
                    if self.whisking
                        val{end+1} = 'sleep:whisking';
                    end
                end
                
                if self.twitching
                    val{end+1} = 'sleep:twitching';
                end
            else
                val{end+1} = 'undefined';
            end
            
            if self.twitching
                val{end+1} = 'twitching';
            end

            if self.manual_sleep
                val{end+1} = 'rem';
                val{end+1} = 'nrem';
                val{end+1} = 'is';

                if self.motion
                    val{end+1} = 'rem:motion';
                    val{end+1} = 'nrem:motion';
                    val{end+1} = 'is:motion';
                else
                    if self.whisking
                        val{end+1} = 'rem:whisking';
                        val{end+1} = 'nrem:whisking';
                        val{end+1} = 'is:whisking';
                    end
                    if self.locomotion
                        val{end+1} = 'rem:locomotion';
                        val{end+1} = 'nrem:locomotion';
                        val{end+1} = 'is:locomotion';
                    end
                end
                
                if self.twitching
                    val{end+1} = 'rem:twitching';
                    val{end+1} = 'nrem:twitching';
                    val{end+1} = 'is:twitching';
                end
            end

            if self.awakening
                val{end+1} = 'awakening';
                if self.differentiate_awakening
                    val{end+1} = 'rem:awakening';
                    val{end+1} = 'nrem:awakening';
                    val{end+1} = 'is:awakening';
                end
            end

            if self.quiet_wakefulness
                val{end+1} = 'quiet';
            end

            if self.motion
                val{end+1} = 'motion';
            else
                if self.whisking
                    val{end+1} = 'whisking';
                end
                if self.locomotion
                    val{end+1} = 'locomotion';
                end
            end
            
            
               
            %% Removing States
            if self.ignore_activity_during_sleep
                I_1 = contains(val,{'whisking','locomotion','motion'});
                I_2 = contains(val,{'sleep:','nrem:','rem:','is:','awakening:'});
                I = I_1 & I_2;
                val(I) = [];
            end
            
            %% wake_and_sleep_is_merged_states makes the states much easier.
            if self.wake_and_sleep_is_merged_states
                val = {'undefined','sleep','wake'};
            end
            
            val = sort(val);
        end
        
        function set.preset(self,val)
            apply_preset(self,val);
        end
        
        function val = get.preset(self)
            val = self.preset_;
        end
        
        function set.quiet_wakefulness(self,val)
            self.preset_ = '';
            self.quiet_wakefulness_ = val;
        end
        
        function val = get.quiet_wakefulness(self)
            val = self.quiet_wakefulness_;
        end
        
        function set.quiet_wakefulness_minimum_duration(self,val)
            self.preset_ = '';
            self.quiet_wakefulness_minimum_duration_ = val;
        end
        
        function val = get.quiet_wakefulness_minimum_duration(self)
            val = self.quiet_wakefulness_minimum_duration_;
        end
        
        function set.quiet_wakefulness_padding_before(self,val)
            self.preset_ = '';
            self.quiet_wakefulness_padding_before_ = val;
        end
        
        function val = get.quiet_wakefulness_padding_before(self)
            val = self.quiet_wakefulness_padding_before_;
        end
        
        function set.quiet_wakefulness_padding_after(self,val)
            self.preset_ = '';
            self.quiet_wakefulness_padding_after_ = val;
        end
        
        function val = get.quiet_wakefulness_padding_after(self)
            val = self.quiet_wakefulness_padding_after_;
        end
        
        function set.wake_and_sleep(self,val)
            self.preset_ = '';
            self.wake_and_sleep_ = val;
        end
        
        function val = get.wake_and_sleep(self)
            val = self.wake_and_sleep_;
        end
        
        function set.motion(self,val)
            self.preset_ = '';
            self.motion_ = val;
        end
        
        function val = get.motion(self)
            val = self.motion_;
        end
        
        function set.locomotion(self,val)
            self.preset_ = '';
            self.locomotion_ = val;
        end
        
        function val = get.locomotion(self)
            val = self.locomotion_;
        end
        
        function set.locomotion_padding_before(self,val)
            self.preset_ = '';
            self.locomotion_padding_before_ = val;
        end
        
        function val = get.locomotion_padding_before(self)
            val = self.locomotion_padding_before_;
        end
        
        function set.locomotion_padding_after(self,val)
            self.preset_ = '';
            self.locomotion_padding_after_ = val;
        end
        
        function val = get.locomotion_padding_after(self)
            val = self.locomotion_padding_after_;
        end
        
        function set.whisking(self,val)
            self.preset_ = '';
            self.whisking_ = val;
        end
        
        function val = get.whisking(self)
            val = self.whisking_;
        end
        
        function set.whisking_padding_before(self,val)
            self.preset_ = '';
            self.whisking_padding_before_ = val;
        end
        
        function val = get.whisking_padding_before(self)
            val = self.whisking_padding_before_;
        end
        
        function set.whisking_padding_after(self,val)
            self.preset_ = '';
            self.whisking_padding_after_ = val;
        end
        
        function val = get.whisking_padding_after(self)
            val = self.whisking_padding_after_;
        end
        
        function set.twitching(self,val)
            self.preset_ = '';
            self.twitching_ = val;
        end
        
        function val = get.twitching(self)
            val = self.twitching_;
        end
        
        function set.twitching_max_duration(self,val)
            self.preset_ = '';
            self.twitching_max_duration_ = val;
        end
        
        function val = get.twitching_max_duration(self)
            val = self.twitching_max_duration_;
        end
        
        function set.manual_sleep(self,val)
            self.preset_ = '';
            self.manual_sleep_ = val;
        end
        
        function val = get.manual_sleep(self)
            val = self.manual_sleep_;
        end
        
        function set.manual_sleep_padding_before(self,val)
            self.preset_ = '';
            self.manual_sleep_padding_before_ = val;
        end
        
        function val = get.manual_sleep_padding_before(self)
            val = self.manual_sleep_padding_before_;
        end
        
        function set.manual_sleep_padding_after(self,val)
            self.preset_ = '';
            self.manual_sleep_padding_after_ = val;
        end
        
        function val = get.manual_sleep_padding_after(self)
            val = self.manual_sleep_padding_after_;
        end
        
        function set.awakening(self,val)
            self.preset_ = '';
            self.awakening_ = val;
        end
        
        function val = get.awakening(self)
            val = self.awakening_;
        end
        
        function set.differentiate_awakening(self,val)
            self.preset_ = '';
            self.differentiate_awakening_ = val;
        end
        
        function val = get.differentiate_awakening(self)
            val = self.differentiate_awakening_;
        end
        
        function set.ignore_activity_during_sleep(self,val)
            self.preset_ = '';
            self.ignore_activity_during_sleep_ = val; %#ok<*MCSUP>
        end
        
        function val = get.ignore_activity_during_sleep(self)
            val = self.ignore_activity_during_sleep_;
        end
        
        function set.wake_and_sleep_is_merged_states(self,val)
            self.preset_ = '';
            self.wake_and_sleep_is_merged_states_ = val; %#ok<*MCSUP>
        end
        
        function val = get.wake_and_sleep_is_merged_states(self)
            val = self.wake_and_sleep_is_merged_states_;
        end
        
    end
    
end

