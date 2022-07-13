clear all
%%
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('diameter_green'));
scans = scans(scans.has_var('diameter_red'));
%%
for i = 1:length(scans)
    diameter_green = scans(i).load_var('diameter_green');
    diameter_red = scans(i).load_var('diameter_red');
    
    % Create a new table containing vessel wall positiono of both channels.
    vessel_wall = diameter_green;
    vessel_wall.diameter = [];
    vessel_wall.vessel_upper = [];
    vessel_wall.vessel_lower = [];
    vessel_wall.endfoot_upper = {diameter_green.vessel_upper{1} * diameter_green.vessel_dx};
    vessel_wall.endfoot_lower = {diameter_green.vessel_lower{1} * diameter_green.vessel_dx};
    vessel_wall.lumen_upper = {diameter_red.vessel_upper{1} * diameter_red.vessel_dx};
    vessel_wall.lumen_lower = {diameter_red.vessel_lower{1} * diameter_red.vessel_dx};
    vessel_wall.time = {(0:length(diameter_red.vessel_upper{1})-1) / diameter_red.vessel_fs};
    
    % Ignore samples
    % Init an array indicating samples that should be ignored. Assume the
    % length of the red and the green channel is the same, as they should.
    I_ignore = false(1, length(diameter_green.diameter{1}));
    % Fill the array based on episodes marked on the green channel.
    ignored_episodes_green = scans(i).load_var("ignored_episodes_green",[]);
    if ~isempty(ignored_episodes_green)
        for j = 1:height(ignored_episodes_green)
            st = round(ignored_episodes_green.start(j));
            en = round(ignored_episodes_green.end(j));
            if en > length(I_ignore)
                en = length(I_ignore);
            end
            I_ignore(st:en) = true;
        end
    end
    % Fill the array based on episodes marked on the red channel.
    ignored_episodes_red = scans(i).load_var("ignored_episodes_red",[]);
    if ~isempty(ignored_episodes_red)
        for j = 1:height(ignored_episodes_red)
            st = round(ignored_episodes_red.start(j));
            en = round(ignored_episodes_red.end(j));
            if en > length(I_ignore)
                en = length(I_ignore);
            end
            I_ignore(st:en) = true;
        end
    end
    
    % Assign ignored samples on both channels as NaN.
    vessel_wall.endfoot_upper{1}(I_ignore) = nan;
    vessel_wall.endfoot_lower{1}(I_ignore) = nan;
    vessel_wall.lumen_upper{1}(I_ignore) = nan;
    vessel_wall.lumen_lower{1}(I_ignore) = nan;
    
    scans(i).save_var(vessel_wall);
end

begonia.logging.log(1,'Finished');
