function tbl = roi_response_per_trial(tm)

tbl = dogbane.tables.roi.roi_response_per_episode(tm);

[G,genotype,experiment,mouse,trial,state,roi_group] = findgroups(tbl.genotype, ...
    tbl.experiment,tbl.mouse,tbl.trial,tbl.state,tbl.roi_group);

avg_response = splitapply(@(x,w) sum(x.*w)/sum(w),tbl.avg_response,tbl.state_duration,G);

tbl = table(genotype,experiment,mouse,trial,state,roi_group,avg_response);

end

