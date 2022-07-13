function tbl = roa_events(tm,roa_table_var_name,states_var_name)
if nargin < 2
    roa_table_var_name = 'highpass_thresh_roa_table';
end
if nargin < 3
    states_var_name = 'states';
end

trials = tm.get_trials();

tbl = {};

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,sprintf('roa_table %d/%d',i,length(trials)));
    
    tr = trials(i).rec_rig_trial;
    ts = trials(i).tseries;
    
    roa_table   = ts.load_var(roa_table_var_name,[]);
    
    if isempty(roa_table)
        continue;
    end
    
    states      = tr.load_var(states_var_name);
    
    % Add columns to roa_table.
    roa_table.state = categorical(repmat({'undefined'},height(roa_table),1));
    roa_table.ts_uuid = categorical(repmat({ts.uuid},height(roa_table),1));
    
    % Create the indicies of the roa table. 
    I_1 = 1:height(roa_table);
    % Convert the event times into indices of states.
    I_2 = round(roa_table.roa_t_start * states.states_fs) + 1;
    
    % Remove events outside of the states trace in both index lists. 
    I = I_2 > length(states.states_trace);
    I_1(I) = [];
    I_2(I) = [];
    
    roa_table.state(I_1) = states.states_trace(I_2);
    
    roa_table(roa_table.state == 'undefined',:) = [];
    
    tbl{i} = roa_table;
end

tbl(cellfun(@isempty,tbl)) = [];

tbl = cat(1,tbl{:});

%% Add metadata
tbl_ids = alyssum_v2.tables.trial_ids(tm);

tbl = innerjoin(tbl_ids,tbl);
%%
tbl.roa_dur = tbl.roa_t_end - tbl.roa_t_start;
end

