classdef Trial < begonia.data_management.DataLocationAdapter
    
    properties
        rec_rig_trial
        tseries
        
        trial_id
        genotype
        experiment
        mouse
        name
        start_time
        optical_zoom
    end
    
    methods
        
        function val = get.optical_zoom(self)
            if ~isempty(self.tseries)
                val = self.tseries.optical_zoom;
            else
                val = nan;
            end
        end
        
        function val = get.start_time(self)
            if ~isempty(self.rec_rig_trial)
                val = self.rec_rig_trial.start_time;
            elseif ~isempty(self.tseries)
                val = self.tseries.start_time;
            else
                val = NaT;
            end
        end
        
        function val = get.name(self)
            val = self.trial_id;
            
            if isempty(val)
                if ~isempty(self.tseries)
                    val = self.tseries.name;
                elseif ~isempty(self.rec_rig_trial)
                    val = self.rec_rig_trial.name;
                else
                    val = '';
                end
            end
        end
        
        function val = get.trial_id(self)
            if ~isempty(self.rec_rig_trial)
                val = self.rec_rig_trial.load_var('trial','');
            else
                val = '';
            end
        end
        
        function val = get.genotype(self)
            if ~isempty(self.rec_rig_trial)
                val = self.rec_rig_trial.load_var('genotype','');
            else
                val = '';
            end
        end
        
        function val = get.mouse(self)
            if ~isempty(self.rec_rig_trial)
                val = self.rec_rig_trial.load_var('mouse','');
            else
                val = '';
            end
        end
        
        function val = get.experiment(self)
            if ~isempty(self.rec_rig_trial)
                val = self.rec_rig_trial.load_var('experiment','');
            else
                val = '';
            end
        end
    end
end

