scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red_baseline') | scans.has_var('diameter_green_baseline'));

dx = nan(length(scans),1);
for i = 1:length(scans)
    d = scans(i).load_var('diameter_red_baseline',[]);
    if isempty(d)
        d = scans(i).load_var('diameter_green_baseline');
    end
    
    
    dx(i) = d.vessel_dx(1);
end
%%
f = figure;
histogram(dx)
xlabel('Spatial resolution (um)')
ylabel('# trials')