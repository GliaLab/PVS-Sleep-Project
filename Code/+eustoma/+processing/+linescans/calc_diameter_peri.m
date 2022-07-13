begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_red'));
scans = scans(scans.has_var('diameter_green'));
%%
for i = 1:length(scans)
    diameter_red = scans(i).load_var('diameter_red');
    diameter_green = scans(i).load_var('diameter_green');
    
    diameter_peri = diameter_red;
    diameter_peri.vessel_upper = [];
    diameter_peri.vessel_lower = [];
    for j = 1:height(diameter_peri)
        green = diameter_green.diameter{j};
        red = diameter_red.diameter{j};
        diameter_peri.diameter{j} = green - red;
        diameter_peri.area{j} = green .^ 2 * pi - red .^ 2 * pi;
    end
    
    scans(i).save_var(diameter_peri);
end