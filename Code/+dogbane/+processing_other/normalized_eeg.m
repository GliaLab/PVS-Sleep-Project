function normalized_eeg(tm)

trials = tm.get_trials();

%% Gather all eeg signals and states in a table, along with the mouse ID.
o = struct();
cnt = 1;

begonia.util.logging.backwrite()
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,'%d/%d',i,length(trials));
    
    tr = trials(i).rec_rig_trial;
    ts = trials(i).tseries;
    
    if isempty(tr)
        continue;
    end
    
    states = tr.load_var('states',[]);
    eeg = tr.load_var('eeg',[]);
    eeg = eeg - median(eeg);
    
    if isempty(states) || isempty(eeg)
        continue;
    end
    
    o(cnt).mouse = tr.load_var('mouse');
    o(cnt).eeg = eeg;
    o(cnt).eeg_fs = tr.load_var('eeg_fs');
    o(cnt).states = states.states_trace;
    o(cnt).states_fs = states.states_fs;
    o(cnt).trial_object = tr;
    
    cnt = cnt + 1;
end

tbl = struct2table(o,'AsArray',true);
tbl.mouse = categorical(tbl.mouse);
%% Calculate a normalization factor for each mouse. 
eeg_fs = tbl.eeg_fs(1);
states_fs = tbl.states_fs(1);

G = findgroups(tbl.mouse);
w = splitapply(@get_norm_factor, ...
    tbl.eeg,tbl.eeg_fs,tbl.states,tbl.states_fs, ...
    G);
%% Apply the normalization factor to each trial/eeg trace. 
w = w(G);
tbl.eeg_norm = cellfun(@(x,y) {x / y}, tbl.eeg, num2cell(w));

%% Assign the normalized eeg.
for i = 1:height(tbl)
    tr = tbl.trial_object(i);
    eeg_norm = tbl.eeg_norm{i};
    tr.save_var(eeg_norm);
end

end

function w = get_norm_factor(eeg,eeg_fs,states,states_fs)
    
    eeg_fs = eeg_fs(1);
    
    states_fs = states_fs(1);
    
    eeg_merged_nrem = [];
    
    for i = 1:length(eeg)
        eeg_trace = eeg{i};
        eeg_t = (0:length(eeg_trace)-1)/eeg_fs;
        
        states_t = (0:length(states{i})-1)/states_fs;
        
        nrem = states{i} == 'nrem';
        nrem = begonia.stage_functions.erode_logical(nrem,round(2.5*states_fs));
        nrem = begonia.stage_functions.dilate_logical(nrem,round(2.5*states_fs));
        
        nrem = begonia.stage_functions.align_indices(eeg_t,states_t,nrem);
        
        eeg_nrem = eeg_trace(nrem);
        
        eeg_merged_nrem = [eeg_merged_nrem,eeg_nrem];
    end
    
    
    if isempty(eeg_merged_nrem)
        w = nan;
    else
        freq_band = [0.5 30];
        w = sqrt(bandpower(eeg_merged_nrem, eeg_fs, freq_band));
    end
end
