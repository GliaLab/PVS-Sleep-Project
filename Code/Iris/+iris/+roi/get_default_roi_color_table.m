function color_table = get_default_roi_color_table()

roi_group = ["Ca", "Ve", "Ar", "AS", "AP", "Gp", "AE", "Cap", "NS", "Np", "ND", "NA"]';

color = zeros(0,3);
color(1,:) = [1,0,1];
color(2,:) = [0,0,1]; 
color(3,:) = [1,0,0]; 
color(4:4+9-1,:) = hsv(9);

color_table = table(roi_group,color);

end

