begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('vessels_red_raw') | scans.has_var('vessels_green_raw'));
%%
for i = 1:length(scans)
    begonia.logging.log(1,'Scan %d/%d',i,length(scans));
    vessels_red = scans(i).load_var('vessels_red_raw');
    vessels_green = scans(i).load_var('vessels_green_raw',[]);
    
    crosstalk_factor = scans(i).load_var('crosstalk_factor',0);
    
    N_vessels = height(vessels_red);
    
    for j = 1:N_vessels
        img_red = vessels_red.vessel{j};

        if isempty(vessels_green)
            vessels_red.vessel{j} = img_red;
        else
            img_green = vessels_green.vessel{j};

            % Correct crosstalk
            img_red = img_red - crosstalk_factor * img_green;

            vessels_green.vessel{j} = img_green;
            vessels_red.vessel{j} = img_red;
        end
    end
    
    scans(i).save_var(vessels_red);
    if ~isempty(vessels_green)
        scans(i).save_var(vessels_green);
    end
end