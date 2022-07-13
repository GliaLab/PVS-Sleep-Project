function log = read_logfile(logpath)

if ~exist(logpath,'file')
    log = array2table(cell(0,4), ...
        'VariableNames',{'Tick','Time','Code','Message'});
    return;
end

%%
% Convert the log into a Nx4 cell matrix with chars. It is possible the
% last element in each row of the log file contains comma (which is the
% delimiter).
log_tmp = fileread(logpath);
log_tmp = strsplit(log_tmp,"\n");
% Ignore end of file new line 
if isempty(log_tmp{end})
    log_tmp(end) = [];
end
log = cell(length(log_tmp),4);
for i = 1:length(log_tmp)
    J = strfind(log_tmp{i},",");
    log{i,1} = log_tmp{i}(1:J(1)-1);
    log{i,2} = log_tmp{i}(J(1)+2:J(2)-1);
    log{i,3} = log_tmp{i}(J(2)+2:J(3)-1);
    log{i,4} = log_tmp{i}(J(3)+2:end-1);
end
%%
log = cell2table(log,'VariableNames',{'Tick','Time','Code','Message'});
log.Tick = str2double(log.Tick);

time_formats = {'HH:mm:ss.SSS','hh:mm:ss aa'};
% Try each of the time formats, break if successful.
for i = 1:length(time_formats)
    try
        log.Time = datetime(log.Time,'Format',time_formats{i});
        break
    catch e
        if ~strcmp(e.identifier,'MATLAB:datetime:ParseErrs')
            rethrow(e);
        end
    end
end
log.Code = strip(log.Code);
log.Message = strip(log.Message);

end

