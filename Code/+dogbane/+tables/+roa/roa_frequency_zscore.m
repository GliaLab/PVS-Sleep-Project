function roa_frequency_zscore(trial)

tr = trial.rec_rig_trial;
ts = trial.tseries;

dt = ts.dt;
fs = 1/dt;


state_episodes = tr.load_var('state_episodes');
roa_frequency_trace = ts.load_var('highpass_thresh_roa_frequency_trace');

I = false(length(roa_frequency_trace),1);
for i = 1:height(state_episodes)
    if ~ismember(state_episodes.State(i),{'quiet','is','nrem','rem'})
        continue;
    end
    st = round(state_episodes.StateStart(i)*fs)-1;
    en = round(state_episodes.StateEnd(i)*fs);
    
    if en > length(I)
        en = length(I);
    end
    
    I(st:en) = true;
end

if ~any(I)
    ts.clear_var('roa_frequency_zscore');
    return;
end


mu = mean(roa_frequency_trace(I));
sigma = std(roa_frequency_trace(I));

roa_frequency_zscore = (roa_frequency_trace - mu) / sigma;

ts.save_var(roa_frequency_zscore);

end

