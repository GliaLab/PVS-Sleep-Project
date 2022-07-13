function color_table = get_sleep_color_table()
ep_name = ["NREM","IS","REM","Vessel Baseline","Locomotion","Whisking","Quiet","Awakening"]';

color = zeros(0,3);
color(end+1,:) = [117,208,250];
color(end+1,:) = [177,124,246]; 
color(end+1,:) = [82,28,138]; 
color(end+1,:) = [100,256,100];
color(end+1,:) = [230,0,0];
color(end+1,:) = [230,230,0];
color(end+1,:) = [39,143,144];
color(end+1,:) = [256,215,0];
color = color / 256;
color_table = table(ep_name,color);

end

