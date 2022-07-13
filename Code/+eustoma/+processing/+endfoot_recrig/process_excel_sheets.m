
begonia.logging.set_level(1);

trials = eustoma.get_endfoot_recrigs(true);

for i = 1:length(trials)
    begonia.logging.log(1,'process_excel_sheets (%d/%d)',i,length(trials));
    tr = trials(i);
    %% Load xl sheet and create IDs
    % Find parent folder.
    parent_dir = tr.path;
    parent_dir = fileparts(parent_dir);

    % Look for xlsx sheet
    look_in_subdirs = false;
    path_xl_sheet = begonia.path.find_files(parent_dir,'.xlsx',look_in_subdirs);

    % Return if there are no xl sheets. 
    if isempty(path_xl_sheet)
        continue;
    end

    % Select the first file.
    path_xl_sheet = path_xl_sheet{1};

    % Find the trial number of the trial filename. 
    [~,filename,~] = fileparts(tr.path);
    trial_num = regexp(filename,'\d+','match');
    trial_num = str2num(trial_num{1});

    % Read the excel sheet. Turn warning off because matlab does not like one
    % of the column names. 
    warning off
    xl_tbl = readtable(path_xl_sheet);
    warning on
    % Check that all the trial numbers in the excel sheet is correctly parsed
    % as numbers.
    assert(isnumeric(xl_tbl.Trial),...
        'The ''Trial'' column in the excel sheet is not correctly formatted.');

    % Find the row in the table where this trial resides. 
    row = xl_tbl.Trial == trial_num;

    % Check if the trial is in the table.
    if ~any(row)
        continue;
    end
    %% Make trial IDs
    % Find the mouse ID, which is in the filename. 
    [~,filename,~] = fileparts(path_xl_sheet);
    mouse = regexp(filename,'M\d+','match');
    % Assert there is only one found mouse ID.
    assert(length(mouse) == 1,'Cannot find mouse ID from the excel sheet.');
    mouse = mouse{1};

    % Use the experiment folder name as a seed and create an experiment ID from
    % a random string. 
    [parent,dir] = fileparts(path_xl_sheet);
    [parent,dir] = fileparts(parent);
    seed = str2double(dir(12:end));
    rng(seed);
    experiment = char(randi([65,90],1,3));
    experiment = sprintf('%s %s',mouse,experiment);

    % Generate the trial id.
    trial = sprintf('%s %02.0f',experiment,trial_num);
    
    tr.save_var(mouse)
    tr.save_var(experiment)
    tr.save_var(trial)
    
    %% Find sleep episodes

    % Find NREM episodes. 
    if ~iscell(xl_tbl.NREM) || isempty(xl_tbl.NREM{row})
        nrem_tbl = table;
    else
        nrem_intervals = xl_tbl.NREM{row};
        nrem_intervals = regexprep(nrem_intervals,'\s*','');
        % Split them on ; and -. 
        nrem_intervals = strsplit(nrem_intervals,{';','-'});
        % Reshape the numbers into a matrix of where the first column is start the
        % start of the episode and the second in the end. 
        nrem_intervals = reshape(nrem_intervals,2,[])';
        nrem_intervals = str2double(nrem_intervals);

        % Make a table of the data.
        state_start = nrem_intervals(:,1);
        state_end = nrem_intervals(:,2);
        state = repmat({'NREM'},length(state_start),1);
        nrem_tbl = table(state,state_start,state_end);
    end

    % Find IS episodes. 
    if ~iscell(xl_tbl.IS) || isempty(xl_tbl.IS{row})
        is_tbl = table;
    else
        is_intervals = xl_tbl.IS{row};
        is_intervals = regexprep(is_intervals,'\s*','');
        % Split them on ; and -. 
        is_intervals = strsplit(is_intervals,{';','-'});
        % Reshape the numbers into a matrix of where the first column is start the
        % start of the episode and the second in the end. 
        is_intervals = reshape(is_intervals,2,[])';
        is_intervals = str2double(is_intervals);

        % Make a table of the data.
        state_start = is_intervals(:,1);
        state_end = is_intervals(:,2);
        state = repmat({'IS'},length(state_start),1);
        is_tbl = table(state,state_start,state_end);
    end

    % Find REM episodes. 
    if ~iscell(xl_tbl.REM) || isempty(xl_tbl.REM{row})
        rem_tbl = table;
    else
        rem_intervals = xl_tbl.REM{row};
        rem_intervals = regexprep(rem_intervals,'\s*','');
        % Split them on ; and -. 
        rem_intervals = strsplit(rem_intervals,{';','-'});
        % Reshape the numbers into a matrix of where the first column is start the
        % start of the episode and the second in the end. 
        rem_intervals = reshape(rem_intervals,2,[])';
        rem_intervals = str2double(rem_intervals);

        % Make a table of the data.
        state_start = rem_intervals(:,1);
        state_end = rem_intervals(:,2);
        state = repmat({'REM'},length(state_start),1);
        rem_tbl = table(state,state_start,state_end);
    end

    % Concatenate the tables with all the episodes. 
    sleep_episodes = cat(1,nrem_tbl,is_tbl,rem_tbl);

    % Only save the table if it is not empty. 
    if ~isempty(sleep_episodes)

        % Sort the table by the start of the episodes. 
        [~,I] = sort(sleep_episodes.state_start);
        sleep_episodes = sleep_episodes(I,:);

        % Make the states categorical.
        sleep_episodes.state = categorical(sleep_episodes.state);

        % Change the order of the categories by setting them. 
        sleep_episodes.state = setcats(sleep_episodes.state,{'NREM','IS','REM'});

        tr.save_var(sleep_episodes);
    end
    %% Define wake/sleep trial
    % If the pre_sleep column is numeric it means all the values are empty. If
    % anything is written in any row of the column the type will be cell. If
    % the row is empty there is no "pre sleep" (wakefulness) in this trial.
    if isnumeric(xl_tbl.pre_sleep) || isempty(xl_tbl.pre_sleep{row})
        trial_type = 'Sleep';
    else
        trial_type = 'Wake';
    end
    
    tr.save_var(trial_type);
    %% Load awakening and falling asleep timepoints

    % The awakening timepoints column can be numeric or cell depending on the
    % content of the column. 
    switch class(xl_tbl.AwakeningTimepoints)
        case 'cell'
            val = xl_tbl.AwakeningTimepoints{row};

            % Parse the numbers from string. 
            if isempty(val)
                awakening_timepoint = [];
            else
                awakening_timepoint = val;
                awakening_timepoint = strsplit(awakening_timepoint,';');
                awakening_timepoint = reshape(awakening_timepoint,[],1);
                awakening_timepoint = str2double(awakening_timepoint);
            end
        case 'double'
            val = xl_tbl.AwakeningTimepoints(row);
            if isempty(val) || isnan(val)
                awakening_timepoint = [];
            else
                awakening_timepoint = val;
            end

        otherwise
            error();
    end

    % The awakening from column should only have text
    switch class(xl_tbl.AwakeningFrom)
        case 'cell'
            if isempty(xl_tbl.AwakeningFrom{row})
                awakening_from = [];
            else
                awakening_from = xl_tbl.AwakeningFrom{row};
                awakening_from = strsplit(awakening_from,';');
                awakening_from = reshape(awakening_from,[],1);
                % Change from char to categorical. 
                awakening_from = categorical(awakening_from);

                % Set the categories
                awakening_from = setcats(awakening_from,{'nrem','is','rem'});

                % Change the name of the categories.
                awakening_from = renamecats(awakening_from, ...
                    {'nrem','is','rem'}, ...
                    {'NREM awakening','IS awakening','REM awakening'});
            end
        case 'double'
            % This should only be double if the xl-cell is empty and therby
            % parsed as nan. 
            assert(isnan(xl_tbl.AwakeningFrom(row)));
            awakening_from = [];
        otherwise
            error();
    end


    % Load the wake to NREM timepoints. 

    % The wake to NREM timepoints column can be numeric or cell depending on the
    % content of the column. 
    switch class(xl_tbl.wakeToNREM)
        case 'cell'
            val = xl_tbl.wakeToNREM{row};

            % Parse the numbers from string. 
            if isempty(val)
                wake2nrem_timepoint = [];
            else
                wake2nrem_timepoint = val;
                wake2nrem_timepoint = strsplit(wake2nrem_timepoint,';');
                wake2nrem_timepoint = reshape(wake2nrem_timepoint,[],1);
                wake2nrem_timepoint = str2double(wake2nrem_timepoint);
            end
        case 'double'
            val = xl_tbl.wakeToNREM(row);
            if isempty(val) || isnan(val)
                wake2nrem_timepoint = [];
            else
                wake2nrem_timepoint = val;
            end

        otherwise
            error();
    end

    % Create a vector that will be used in the following table
    state = categorical(repmat({'wake to NREM'},length(wake2nrem_timepoint),1));

    % Create a table of the wake2nrem timepoints and the awakening timepoints
    state = [awakening_from;state];
    timepoint = [awakening_timepoint;wake2nrem_timepoint];

    wake_sleep_transitions = table(state,timepoint);

    % Save if not empty.
    if ~isempty(wake_sleep_transitions)
        % Change the order of the categories. 
        wake_sleep_transitions.state = setcats(wake_sleep_transitions.state, ...
            {'NREM awakening','IS awakening','REM awakening','wake to NREM'});

        % Sort
        [~,I] = sort(wake_sleep_transitions.timepoint);
        wake_sleep_transitions = wake_sleep_transitions(I,:);

        tr.save_var(wake_sleep_transitions);
    end

    %% Read the eeg / emg idx.
    
    ephys_idx = struct;
    ephys_idx.eeg_idx = xl_tbl.eeg(row);
    ephys_idx.emg_idx = xl_tbl.emg(row);
    tr.save_var(ephys_idx);

    %% Read depth. 

    if ~isempty(xl_tbl.Depth(row)) && ~isnan(xl_tbl.Depth(row))
        depth = xl_tbl.Depth(row);
        tr.save_var(depth);
    end
end

