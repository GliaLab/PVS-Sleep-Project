function roi_frequency_traces(ts)

fs = 30;
dt = 1/fs;

%% Count rois
rois = ts.load_var('roi_array');
rois = struct2table(rois);

[G,roi_group] = findgroups(rois.group);
roi_N = splitapply(@length,rois.group,G);
rois = table(roi_group,roi_N);
rois.roi_group = categorical(rois.roi_group);
%%
t = 0:seconds(ts.duration)*fs;

roi_events = ts.load_var('roi_events');
if isempty(roi_events)
    % If there are no events, but there are ROIs, create a frequency trace
    % which is zero throughout the trial for all the ROIs. 
    roi_frequency_traces = rois;
    roi_frequency_traces.roi_frequency_trace = zeros(height(roi_frequency_traces),length(t)-1);
    % Change the order of the colums.
    roi_frequency_traces = roi_frequency_traces(:,{'roi_group','roi_frequency_trace','roi_N'});
else
    roi_events.x_start_idx = round(roi_events.x_start * fs) + 1;

    [G,roi_group] = findgroups(roi_events.roi_group);
    % Put the frequency traces in cells as different trials have different
    % lengths. 
    roi_frequency_trace = splitapply(@(x)histcounts(x,t),roi_events.x_start_idx,G);

    roi_frequency_traces = table(roi_group,roi_frequency_trace);
    % Outerjoin will fill 'roi_frequency_trace' with an NaNs if
    % there are ROI groups that did not have any events. 
    roi_frequency_traces = outerjoin(roi_frequency_traces,rois,'MergeKeys',true);
    roi_frequency_traces.roi_frequency_trace = roi_frequency_traces.roi_frequency_trace ./ dt ./ roi_frequency_traces.roi_N;
    roi_frequency_traces.roi_frequency_trace(isnan(roi_frequency_traces.roi_frequency_trace)) = 0;
end
% Convert the rows to cell as this table will be aggreated with other
% trials that have different durations. 
roi_frequency_traces.roi_frequency_trace = mat2cell(roi_frequency_traces.roi_frequency_trace,ones(1,height(roi_frequency_traces)),length(t)-1);
%%
ts.save_var(roi_frequency_traces)
end

