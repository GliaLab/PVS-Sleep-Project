function progress = log_progress(i,len,interval,text)
if nargin < 3
    interval = 5; % Seconds.
end
if nargin < 4
    text = "Progress";
end

% Interpret second input, len. Which can be table, array or natural number.
if istable(len)
    % Set len to the length of the table.
    len = height(len);
elseif length(len) ~= 1
    % Len is an array.
    len = length(len);
end

% Calculate pogress in percent.
progress = (i-1)/(len-1)*100;

% Log progress.
if i == 1 || i == len || toc > interval
    begonia.logging.log(1,"%s %d/%d (%.2f%%)",text,i,len,progress);
    tic;
end

end

