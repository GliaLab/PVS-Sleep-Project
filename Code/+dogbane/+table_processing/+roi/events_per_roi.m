function tbl = events_per_roi(rois,roi_events)

% Group the event table by roi_id and count how many events are in each
% roi.
[G,tbl] = findgroups(roi_events(:,{'roi_id'}));
tbl.num_events = splitapply(@length,roi_events.trial,G);

% Include the rois that do not have any events by doing a left outer join. 
tbl = outerjoin(rois,tbl,'Keys',{'roi_id'},'MergeKeys',true,'Type','left');
% The NaNs means zero events in those rois. 
tbl.num_events(isnan(tbl.num_events)) = 0;

end

