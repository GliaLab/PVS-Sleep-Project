function tbl = has_states(trials)

o = struct;

begonia.util.logging.backwrite();
for i = 1:length(trials)
    begonia.util.logging.backwrite(1,sprintf('has_states %d/%d',i,length(trials)));
    try 
        tbl = trials(i).rec_rig_trial.load_var('state_episodes');
        tbl_aw = trials(i).rec_rig_trial.load_var('state_episodes_transitions');
        o(i).has_rem        = ismember('rem',tbl.State);
        o(i).has_nrem       = ismember('nrem',tbl.State);
        o(i).has_is         = ismember('is',tbl.State);
        o(i).has_quiet      = ismember('quiet',tbl.State);
        o(i).has_whisking   = ismember('whisking',tbl.State);
        o(i).has_locomotion = ismember('locomotion',tbl.State);
        o(i).has_awakening  = any(ismember({'rem:awakening','nrem:awakening','is:awakening'},tbl_aw.State));
    catch e
        o(i).has_rem        = false;
        o(i).has_nrem       = false;
        o(i).has_is         = false;
        o(i).has_quiet      = false;
        o(i).has_whisking   = false;
        o(i).has_locomotion = false;
        o(i).has_awakening  = false;
    end
end

tbl = struct2table(o,'AsArray',true);

end

