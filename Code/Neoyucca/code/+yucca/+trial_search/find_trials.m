function trials = find_trials(varargin)
    import begonia.logging.*;

    p = inputParser;
    p.addRequired('dir_path',...
        @(x) validateattributes(x,{'string','char'},{'nonempty'}));
    p.addParameter('class_constructor',@yucca.trial.Trial,...
        @(x) validateattributes(x,{'function_handle'},{'nonempty'}));
    p.addParameter('ignore_str','', ...
        @(x) validateattributes(x,{'char'},{}));
    p.parse(varargin{:});
    begonia.util.dump_inputParser_vars_to_caller_workspace(p);
    
    dir_path = char(dir_path);

    log(1,'Looking for trials');
    % find all subdirs:
    log(1, 'Discovering directories');
    dirs = begonia.path.list_dirs(dir_path,ignore_str);

    % identify what dirs are trials
    cnt = 1;
    backwrite();
    for i = 1:length(dirs)
        backwrite(1,sprintf('Scanning folder (%d/%d)',i,length(dirs)));
        path = dirs{i};

        % if it's a trial, generate a trial object:
        if yucca.trial_search.is_trial(path)
            try
                trials(cnt) = class_constructor(path); %#ok<AGROW>
                cnt = cnt + 1;
            catch err
                warning(['Error loading trial using find_trials :: ' path ' :: ' err.message ]);
                continue;
            end
        end
    end
    
    if ~exist('trials','var')
        trials = [];
    end
    log(1,sprintf('Found %d trials',length(trials)))

end

