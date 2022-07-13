begonia.logging.set_level(1);

scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red'));

for i = 1:length(scans)
    diameter_red = scans(i).load_var('diameter_red');
    if isempty(diameter_red.diameter{1}) || all(isnan(diameter_red.diameter{1}))
        scans(i).clear_var('diameter_red');
        disp(i)
    end
end