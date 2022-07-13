clear all

%%
begonia.logging.set_level(1);
scans = eustoma.get_linescans();
scans = scans(scans.has_var('clean_episodes'));
scans = scans(scans.has_var('vessels_green'));
scans = scans(scans.has_var('vessels_red'));

%%
for i = 1:length(scans)
    begonia.logging.log(1,"Scan %d/%d",i,length(scans));
    
    vessels_green = scans(i).load_var('vessels_green');
    vessels_red = scans(i).load_var('vessels_red');
    
    green = vessels_green.vessel{1};
    red = vessels_red.vessel{1};
    
    vessel_name = string(vessels_green.vessel_name(1));
    
    % Only export penetrating arteriole.
    if vessels_green.vessel_type ~= "Penetrating Arteriole"
        continue;
    end
    
    % Export sleep episodes.
    clean_episodes = scans(i).load_var('clean_episodes');
    if isempty(clean_episodes) || ~any(clean_episodes.ep == "Clean REM")
        continue;
    end
    
    filename = fullfile(eustoma.get_plot_path, "Linescan Vessel Images Clean REM Pen.", vessel_name + " clean sleep episodes.csv");
    begonia.path.make_dirs(filename);
    writetable(clean_episodes,filename)
    
    % Export table with info. 
    vessels_green.vessel = [];
    filename = fullfile(eustoma.get_plot_path, "Linescan Vessel Images Clean REM Pen.", vessel_name + " info.csv");
    begonia.path.make_dirs(filename);
    writetable(vessels_green,filename)
    
    % Export green tif.
    filename = fullfile(eustoma.get_plot_path, "Linescan Vessel Images Clean REM Pen.", vessel_name + " endfoot.tif");
    begonia.path.make_dirs(filename);
    t = Tiff(filename,'w');  
    tagstruct.ImageLength = size(green,1);
    tagstruct.ImageWidth = size(green,2);
    tagstruct.SampleFormat = Tiff.SampleFormat.Int;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression = Tiff.Compression.None;  
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky; 
    tagstruct.Software = 'MATLAB';
    setTag(t, tagstruct)
    write(t, green)
    close(t)
    
    % Export green tif.
    filename = fullfile(eustoma.get_plot_path, "Linescan Vessel Images Clean REM Pen.", vessel_name + " lumen.tif");
    begonia.path.make_dirs(filename);
    t = Tiff(filename,'w');  
    tagstruct.ImageLength = size(red,1);
    tagstruct.ImageWidth = size(red,2);
    tagstruct.SampleFormat = Tiff.SampleFormat.Int;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 16;
    tagstruct.SamplesPerPixel = 1;
    tagstruct.Compression = Tiff.Compression.None;  
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky; 
    tagstruct.Software = 'MATLAB';
    setTag(t, tagstruct)
    write(t, red)
    close(t)
end
