function tbl = has_vars(trials)

o = struct;

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,sprintf('has_vars %d/%d',i,length(trials)));
    if isempty(trials(i).tseries)
        o(i).has_gp_traces          = false;
        o(i).has_roi_array          = false;
        o(i).has_neuron_channel     = false;
        o(i).has_neuron_rois        = false;
    else
        o(i).has_gp_traces          = trials(i).tseries.has_var('ca_signal_gliopil_traces');
        o(i).has_roi_array          = trials(i).tseries.has_var('roi_array');
        o(i).has_neuron_channel     = trials(i).tseries.channels > 1;
        o(i).has_neuron_rois        = trials(i).tseries.has_var('ca_signal_neurons_subtracted');
    end
    
    if isempty(trials(i).rec_rig_trial)
        o(i).has_manual_scoring = false;
    else
        o(i).has_manual_scoring = trials(i).rec_rig_trial.has_var('sleep_stages');
    end
end

tbl = struct2table(o,'AsArray',true);

end

