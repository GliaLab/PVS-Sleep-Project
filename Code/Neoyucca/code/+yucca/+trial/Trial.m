classdef Trial < begonia.data_management.DataLocation & dynamicprops & begonia.data_management.DataInfo
    %TRIAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %% For DataInfo
        uuid
        name
        
        type
        source
        
        % DataInfo props:
        start_time_abs
        duration
        time_correction
        
        %% Old props
        Path
        %Name
        DateRecorded
        TimeStart
        TimeEnd 
        DateRecordedFallbackUsed
        Note
        Duration
    end

    properties(Access = private)
       Cached 
    end
    
    properties(Transient)
        Log
        ExperimentLog
    end
    
    methods
        
        function obj = Trial(path)
            import begonia.logging.log;

            path = char(path);
            
            obj@begonia.data_management.DataLocation(path);
            obj.dl_ensure_has_uuid();
            obj.uuid = obj.dl_unique_id;
            obj.Path = path;

            [~,name, ~] = fileparts(char(path));
            obj.name = name;

            % prepare for log:
            obj.Cached = struct;
            
            % Read and save the logs. 
            [log_exp,log_part] = obj.read_logs();
            obj.ExperimentLog = log_exp;
            obj.Log = log_part;
            
            % cache some basic data:
            obj.DateRecorded = obj.get_recorded_date(); % this is on the experiment
            obj.TimeStart = obj.get_time_start();
            obj.TimeEnd = obj.get_time_end();
            obj.Duration = seconds(obj.TimeEnd - obj.TimeStart);
            
            % alter time to be first line in out log:
            fltime = obj.Log{1,'Time'};
            obj.DateRecorded.Hour = fltime.Hour;
            obj.DateRecorded.Minute = fltime.Minute;
            obj.DateRecorded.Second = fltime.Second;      
            obj.DateRecorded.Format = 'dd-MMM-uuuu HH:mm:ss.SSS';
            
            obj.load_timeinfo;
            
            % metadata:
            obj.type = 'Recording rig output';
            obj.source = 'Letten Center recording rig v1';
            
            % read notes file:
            notefile = fullfile(char(path), 'Notes.txt');
            obj.Note = fileread(notefile);
            
        end
        
        function load_timeinfo(obj)
            obj.start_time_abs = datetime(obj.TimeStart);
            dr = seconds(obj.Duration);
            dr.Format = 'hh:mm:ss';
            obj.duration = dr; 
            
        end
        
        % Date the experiment was recorded:
        function d = get_recorded_date(obj)
            % we'll try to read the RECDATE code of the log to see
            % when it was recorded, or fall back to log file date if not:
            
            rd_entries = obj.ExperimentLog(strcmp(obj.ExperimentLog.Code, 'RECDATE'),:);
            
            if ~isempty(rd_entries)
                dm = rd_entries{1, 'Message'};
                tm = rd_entries{1, 'Time'};
                timestring = [char(dm) ' ' datestr(tm, 'HH:MM:SS.FFF') ];
                try
                    d = datetime(timestring, 'InputFormat', 'MM/dd/uuuu HH:mm:ss.SSS');
                catch
                    d = datetime(timestring, 'InputFormat', 'dd-MMM-yy HH:mm:ss.SSS');
                end
                obj.DateRecordedFallbackUsed = 0;
            else
                % fallback mechanism:
                finfo = dir(fullfile(char(obj.Path), 'Logpart.csv'));
                d  = datetime(finfo.date);
                obj.DateRecordedFallbackUsed = 1;
            end
        end
        
        % Time the experiment started
        function ts = get_time_start(obj)
            % first line of log is considered start time:
            
            ix = find(strcmp(obj.Log.Code, 'TRIAL_START'), 1, 'first');
            if isempty(ix)
                 ix = 1;
            end
            ts = datetime(... 
                obj.DateRecorded.Year, ...
                obj.DateRecorded.Month, ...
                obj.DateRecorded.Day, ...
                obj.Log{ix, 'Time'}.Hour, ...
                obj.Log{ix, 'Time'}.Minute, ...
                obj.Log{ix, 'Time'}.Second);
        end
        
        % Time the experiment ended
        function te = get_time_end(obj)
            te = datetime(... 
                obj.DateRecorded.Year, ...
                obj.DateRecorded.Month, ...
                obj.DateRecorded.Day, ...
                obj.Log{end, 'Time'}.Hour, ...
                obj.Log{end, 'Time'}.Minute, ...
                obj.Log{end, 'Time'}.Second);
        end
        
        function [log_exp,log_part] = read_logs(obj)
            % Read both the experiment log and the logpart file of the
            % trial.
            
            log_exp_path = fullfile(char(obj.Path), '../Log.csv');
            log_exp = yucca.trial.read_logfile(log_exp_path); 
            
            % find first entry of our logpart:
            log_part_path = fullfile(char(obj.Path), './Logpart.csv');
            log_part = yucca.trial.read_logfile(log_part_path);
            
            
            if isempty(log_exp)
                return;
            end
            
            ftick = log_part.Tick(1);
            ltick = log_part.Tick(end);

            findex = find(log_exp.Tick == ftick);
            lindex = find(strcmp(log_exp.Code, 'NEW_STATE') & strcmp(log_exp.Message, 'EXP'));
            lindex = lindex(lindex > findex(1));

            if length(lindex) > 0
                lindex = lindex(1);
            else
                lindex = find(log_exp.Tick == ltick);
                %warning(['Could not get extended log for trial ' char(obj.Name)])
            end
            log_part = log_exp(findex:lindex, :);
              
        end
        
        
        % Method to get lines from the extended log based on the code of
        % the line:
        function rows = get_extlog_by_code(obj, code)
            match_indices = strcmp(obj.ExperimentLog.Code, code);
            rows = obj.ExperimentLog(match_indices,:);
        end
        
        
        % Method to get key-value pairs from a log entry as a struct.  This works if
        % the message is on a "key1:value1 ; key2:value2" format.  Only
        % works on one row at a time, so if more than once, user has to
        % specify which one to use:
        function kvps = get_extlog_value_pairs_by_code(obj, code, try_convert_numeric)
            rows = obj.get_extlog_by_code(code);
            kvps = [];
            
            for ri = 1:height(rows)
                row = rows(ri, :);
                data = char(row{:,'Message'});

                kvs = strsplit(data, ';');

                kvp_entry = struct();

                for i = 1:length(kvs)
                    kv = strsplit(char(kvs(i)),':');
                    key = char(strtrim(kv(1)));
                    value = char(strtrim(kv(2)));
                    
                    if try_convert_numeric
                        try
                            converted = str2double(value);
                            if ~isnan(converted)
                                value = converted;
                            end
                        catch
                            
                        end
                    end
                    
                    
                    if ~isempty(value)
                        kvp_entry.(key) = value;
                    else
                        kvp_entry.(key) = [];
                    end
                    
                end
                
                kvps = [kvps kvp_entry];
            end

        end
        
    end
    
end

