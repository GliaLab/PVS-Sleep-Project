function load_sleep_stages_from_xlsx(trials, xlsx_directory)
% Parse xlsx file and get sleep periods. 

begonia.util.logging.vlog(1,sprintf('Loading sleep : %s', xlsx_directory));


files = begonia.path.find_files(xlsx_directory, '.xlsx');

sleep_stages_fs = 30;
sleep_stages_dt = 1/sleep_stages_fs;

%% Clear previous stuff.
trials.clear_var('sleep_stages');
trials.clear_var('sleep_stages_dt');
trials.clear_var('sleep_stages_fs');
trials.clear_var('sleep_stages_t');
trials.clear_var('eeg_idx');
trials.clear_var('emg_idx');
trials.clear_var('emg_delay');

%% Check file integrity.
if isempty(files)
    begonia.util.logging.vlog(1,'Missing sleep scoring');
    return;
end
assert(length(files) < 2, sprintf('Multiple .xlsx files found at:\n\t%s\n',xlsx_directory));
%% Read the xl file.
file = files{1};
sleep_table = readtable(file);

%% Get the trial IDs (last number in the trial folder name)
trial_names = trials.load_var('trial');
trial_num = regexp(trial_names,'\d+','match');
% Make sure output of regexp is a cellstr
if length(trials) == 1
    trial_names = {trial_names};
    trial_num = {trial_num};
end
% Extract the trial ID
trial_ids_objects = zeros(1,length(trial_names));
for i = 1:length(trial_num)
    trial_ids_objects(i) = str2double(trial_num{i}{end});
end

%% Get the trial IDs in the xl sheet
trial_ids_sheet = sleep_table.('trial');
if ~isnumeric(trial_ids_sheet)
    warning('Trial IDs in xl sheet contains non numeric values.');
    trial_ids_sheet = str2double(trial_ids_sheet);
    trial_ids_sheet(isnan(trial_ids_sheet)) = [];
end

%% Load each trial
% For each trial object, find the correct row in the xl sheet and load
% sleep scoring. 
for i = 1:length(trials)
    trial = trials(i);

    % Make sure the trial id exists in the xl table and find which row
    % this trial is in. 
    trial_sheet_row = find(trial_ids_sheet == trial_ids_objects(i));

    % If the trial is not in the xl sheet, skip it.
    if isempty(trial_sheet_row)
        continue
    end

    %% Get the index of where the eeg signal is.
    eeg_idx = sleep_table.('eeg');
    eeg_idx = eeg_idx(trial_sheet_row);
    emg_idx = 3 - eeg_idx;
    if ismember(eeg_idx,[1,2])
        trial.save_var(eeg_idx);
        trial.save_var(emg_idx);
    else
        warning('Invalid eeg idx of %s',trial.path)
    end

    %% Init variables
    samples = round(trial.Duration*sleep_stages_fs);
    sleep_stages = cell(1,samples);
    sleep_stages(:) = {'undefined'};
    sleep_stages = categorical(sleep_stages);
    sleep_stages_t = (0:length(sleep_stages)-1)*sleep_stages_dt;

    % Define the periods that should be in the sheet. 
    sleep_stages_labels = {'pre_sleep','nrem','pre_rem','rem'};
    
    %% Parse each column with sleep stages
    for j = 1:length(sleep_stages_labels)
        % Parse the sleep stages in the correct row.
        text = sleep_table{trial_sheet_row,sleep_stages_labels{j}};
        % Interpret NaN as empty cell and skip;
        if ismissing(text); continue; end
        text = text{1};
        % Remove whitespace
        text = regexprep(text,'\s*','');
        if isempty(text); continue; end
        % Split periods. 
        periods = strsplit(text,';');
        periods(cellfun(@isempty,periods)) = [];

        % Quickfix for pre_sleep scoring. pre_sleep is a scoring of
        % wakefulness, but when it is scored the whole trial is
        % pre_sleep.
        if strcmp(sleep_stages_labels(j),'pre_sleep') && ~isempty(periods)
            sleep_stages(:) = 'pre_sleep';
            break;
        end

        for k = 1:length(periods)
            % Find start and end. 
            tmp = strsplit(periods{k},'-');
            assert(length(tmp) == 2, 'Need exactly one start and end point. Trial: %s',trial.path);
            t_1 = str2double(tmp{1});
            t_2 = str2double(tmp{2});
            % Convert from time to index
            % add 1 because matlab starts indexing from 1.
            t_1 = round(t_1*sleep_stages_fs) + 1;
            % add 1, but also subtract 1 because we want the index right 
            % before the period ends. 
            t_2 = round(t_2*sleep_stages_fs);
            sleep_stages(t_1:t_2) = sleep_stages_labels(j);
        end
    end
    %% Parse awakenings (slightly different from the other sleep stages)
    awakenings = sleep_table{trial_sheet_row,'awakenings'};
    switch class(awakenings)
        case 'cell'
            awakenings = awakenings{1};
            % Remove whitespace
            awakenings = regexprep(awakenings,'\s*','');
            % Check if this is an old version of the awakening definition and if so
            % ignore it (set it to empty).
            if contains(awakenings,'-')
                awakenings = '';
            end
            % Replace comma with dot.
            awakenings = strrep(awakenings,',','.');
            if isempty(awakenings)
                awakenings = [];
            else
                % Split periods. 
                awakenings = strsplit(awakenings,';');
                % Convert to numbers
                awakenings = str2double(awakenings);
            end
            % Convert to indices.
            awakenings = round(awakenings*sleep_stages_fs) + 1;
            assert(~any(isnan(awakenings)),'Value in sheet cannot be interpreted.');
        case 'double'
            if isnan(awakenings)
                awakenings = [];
            else 
                % Convert to indices.
                awakenings = round(awakenings*sleep_stages_fs) + 1;
            end
        otherwise
            error('Unknown format of the xl cell of awakening.')
    end
        
    % (For now) Define a static durtation of each awakening.
    awakening_duration = round(30 * sleep_stages_fs);
    awakenings_end = awakenings + awakening_duration;
    awakenings_end = min(awakenings_end,samples);
    
    if ismember('Awakening_from',sleep_table.Properties.VariableNames)
        awakening_from = sleep_table.Awakening_from{trial_sheet_row};
        awakening_from = regexprep(awakening_from,'\s*','');
        if isempty(awakening_from)
            awakening_from = {};
        else
            awakening_from = strsplit(awakening_from,';');
        end
    else
        awakening_from = cell(1,length(awakenings));
        awakening_from(:) = {''};
    end
    
    assert(~any(~ismember(awakening_from,{'','pre_rem','nrem','rem'})), ...
        'Awakening from can only be empty, pre_rem, nrem or rem.')
    
    for j = 1:length(awakenings)
        if isempty(awakening_from{j})
            str = 'awakenings';
        else
            str = ['awakenings:',awakening_from{j}];
        end
        sleep_stages(awakenings(j):awakenings_end(j)) = str;
    end
    % Check that there are no scoring outside of the duration of the trial.
    assert(length(sleep_stages)==samples);
    %% Save the data. 
    trial.save_var(sleep_stages)
    trial.save_var(sleep_stages_dt)
    trial.save_var(sleep_stages_fs)
    trial.save_var(sleep_stages_t);
    %% Load a variable called emg delay
    if ismember('EMG_delay',sleep_table.Properties.VariableNames)
        if iscell(sleep_table.EMG_delay)
            emg_delay = sleep_table.EMG_delay{trial_sheet_row};
            % Remove whitespace
            emg_delay = regexprep(emg_delay,'\s*','');
            % Replace comma with dot.
            emg_delay = strrep(emg_delay,',','.');
            if isempty(emg_delay)
                emg_delay = [];
            else
                emg_delay = strsplit(emg_delay,';');
                % Convert to numbers
                emg_delay = str2double(emg_delay);
            end
        else
            emg_delay = sleep_table.EMG_delay(trial_sheet_row);
        end
    else
        emg_delay = nan(1,length(awakenings));
    end
    if ~isempty(emg_delay) && ~isempty(awakening_from)
        emg_delay = table(categorical(awakening_from)',emg_delay','VariableNames',{'awakening_from','emg_delay'});
        
        trial.save_var(emg_delay);
    end
end

end

