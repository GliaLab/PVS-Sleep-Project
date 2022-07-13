clear all
%%
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('vessels_green'));

%%

pixel_width = 2;

for i = 1:length(scans)
    begonia.logging.log(1,'Trial %d/%d',i,length(scans));
    
    core_trace = scans(i).load_var('vessels_green');
    
    mid_index = round(size(core_trace.vessel{1},1) / 2);
    half_width = round(pixel_width / 2);
    trace = core_trace.vessel{1}(mid_index - half_width : mid_index + half_width, :);
    trace = mean(trace, 1);
    
    core_trace.core_trace = {trace};
    core_trace.vessel = [];
    
    scans(i).save_var(core_trace);
end