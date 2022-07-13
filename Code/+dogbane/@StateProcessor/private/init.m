function init(self)

N_STATES = dogbane.constants.N_STATES;

state_names = {};
state_names{dogbane.constants.REM} = 'rem';
state_names{dogbane.constants.NREM} = 'nrem';
state_names{dogbane.constants.IS} = 'is';
state_names{dogbane.constants.AWAKENING} = 'awakening';
state_names{dogbane.constants.WHISKING} = 'whisking';
state_names{dogbane.constants.LOCOMOTION} = 'locomotion';
state_names{dogbane.constants.MOTION} = 'motion';
state_names{dogbane.constants.QUIET} = 'quiet';
state_names{dogbane.constants.SLEEP} = 'sleep';
state_names{dogbane.constants.WAKE} = 'wake';
state_names{dogbane.constants.TWITCHING} = 'twitching';

val_set = 0:2^N_STATES - 1;
cat_set = cell(1,length(val_set));

for i = val_set
    I = dec2bin(i,N_STATES) == '1';
    I = logical(I);
    cats = state_names(I);
    if isempty(cats)
        % Only happens for the first index.
        cat_set{i+1} = 'undefined';
    else
        str = sprintf('%s:',cats{:});
        str(end) = [];
        cat_set{i+1} = str;
    end
end

self.val_set = val_set;
self.cat_set = cat_set;
end

