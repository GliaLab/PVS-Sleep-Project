classdef TrialManager < xylobium.TrialManager
    
    methods
        
        function self = TrialManager()
            self.load_dataset();
            self.reset_filters();
        end
        
        function reset_filters(self)
            reset_filters@xylobium.TrialManager(self);
            
            self.add_filter_function(@dogbane.trial_filters.metadata);
            self.add_filter_function(@dogbane.trial_filters.valid_trial);
            self.add_filter_function(@dogbane.trial_filters.has_vars);
            self.add_filter_function(@dogbane.trial_filters.has_states);
            
            self.set_filter('valid_trial','true');
            self.set_filter('ignored_trial','false');
            self.set_filter('genotype',{'ip3_dual','wt_dual'});
            self.set_filter('has_manual_scoring','true');
        end
        
        function load_dataset(self)
            %% Load
            path_tseries = '/Volumes/Storage2/alyssum/tseries_aligned_h5';
            path_rec_rig_trials = '/Volumes/Storage2/alyssum/recrig';
            if ~exist(path_tseries)
                begonia.util.logging.vlog(1,'Default path to data did not exist.');
                path_tseries = uigetdir();
                path_rec_rig_trials = path_tseries;
                if isequal(path_tseries,0)
                    begonia.util.logging.vlog(1,'Returning without loading dataset.');
                    return;
                end
            end
            
            tseries = begonia.scantype.find_tseries(path_tseries);
            rr_trials = yucca.trial_search.find_trials(path_rec_rig_trials);
            
            %% Time align
            [I_tr,I_ts] = begonia.data_management.align_timeinfo(rr_trials,tseries, ...
                'lag',seconds(15), ...
                'time_window',seconds(30), ...
                'set_time_correction',true);

            rr_trials_aligned = rr_trials(I_tr);
            tseries_aligned = tseries(I_ts);

            rr_trials_not_aligned = rr_trials(~ismember(rr_trials,rr_trials_aligned));
            tseries_not_aligned = tseries(~ismember(tseries,tseries_aligned));
            %%
            for i = 1:length(rr_trials_aligned)
                trials(i) = dogbane.Trial();
                trials(i).path = rr_trials_aligned(i).path;
                trials(i).rec_rig_trial = rr_trials_aligned(i);
                trials(i).tseries = tseries_aligned(i);
            end
            cnt = length(trials);
            for i = 1:length(rr_trials_not_aligned)
                trials(i + cnt) = dogbane.Trial();
                trials(i + cnt).path = rr_trials_not_aligned(i).path;
                trials(i + cnt).rec_rig_trial = rr_trials_not_aligned(i);
            end
            cnt = length(trials);
            for i = 1:length(tseries_not_aligned)
                trials(i + cnt) = dogbane.Trial();
                trials(i + cnt).path = tseries_not_aligned(i).path;
                trials(i + cnt).tseries = tseries_not_aligned(i);
            end

            [~,I] = sort([trials.start_time]);

            self.trials = trials(I);
            end


    end
end

