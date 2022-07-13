% This scripts read "Data/TSeries uncorrected" and writes to
% "Data/TSeries" and corrects hemodynamic artifacts.
clear all
%%
begonia.logging.set_level(1);

% Read uncorrected data.
ts = get_tseries(true,"TSeries uncorrected");
ts = ts(ts.has_var("roi_table"));

%%
border = 15;                % remove border pixels
Smo = 3;                    % spatial smooth
window = 176;               % movmean window for extract high-frequency component
bleachCorrection = false;    % whether to correct bleach

% Correct hemodynaic artefacts in each tseries.
tic
for i = 1:length(ts)
    if i == 1 || i == length(ts) || toc > 5
        tic
        begonia.logging.log(1,"%d / %d",i,length(ts))
    end
    
    % Create output filename.
    output_path = ts(i).path;
    output_path = strrep(output_path, "TSeries uncorrected", "TSeries");
    output_path = strrep(output_path, ".tif", "");
    output_path = strrep(output_path, ".h5", "");

    output_path = output_path + ".h5";
    output_path_img  = strrep(output_path, ".h5", "");
    output_path_img  = strrep(output_path, "Data", "Plot");
    output_path_img_png = output_path_img + ".png";
    output_path_img_mean = output_path_img + "mean.png";
    
    % Get data.
    data = ts(i).get_mat(1);

    % Convert to single.
    data = single(data(:,:,:));

    % Remove negative values, give warning if there are many.
    I = data(:) < 0;
    if sum(I)/numel(data) > 0
        warning("%.2f%% of the data are negative! Might have consequences after correction.",sum(I)/numel(data)*100);
    end
    data(I) = 0;

    % Smooth.
    if Smo ~= 0
        data = imgaussfilt(data,Smo);
    end
    
    % average projection
    datMean = mean(data,3);
    datMean = datMean - min(datMean(:));
    datMean = datMean/max(datMean(:));

    % Get dimensions.
    [H,W,T] = size(data);
    
    % Bleach correct.
    if(bleachCorrection)
        data = preprocessDebleach(data, datMean);
    else
        data = reshape(data,[],T);
    end
    
    % Get the vessel mask from the ROIs.
    roi_table = ts(i).load_var("roi_table");
    vessel_region = roi_table.mask{1};

    % Correct.
    % linear regression to fit
    [datCorrect,weights,hfc,vesselreg] = correctHemodynamic(data,vessel_region,window);               
    datCorrect = reshape(datCorrect,[H,W,T]);
    
    begonia.path.make_dirs(output_path_img_png);
    imwrite(vesselreg, output_path_img_png)
    imwrite(datMean, output_path_img_mean)

    % Write new file.
    begonia.path.make_dirs(output_path);
    dim = [H,W,ts(i).channels,T];
    if exist(output_path,"file")
        delete(output_path)
    end
    mat_out = begonia.util.H5Array(output_path,dim,'single', ...
        'dataset_name','/recording');
    begonia.logging.log(1,'Writing %s',output_path);
    % Write channel 1: corrected channel. 
    begonia.logging.log(1,"Writing channel 1")
    try
        mat_out(:,:,1,:) = datCorrect;
    catch
        begonia.logging.log(1,"Error, skipping.")
        continue;
    end

    % Write other channels.
    for ch = 2:ts(i).channels
        begonia.logging.log(1,"Writing channel %d",ch)
        mat = ts(i).get_mat(ch);
        clear data
        mat_out(:,:,ch,:) = single(mat(:,:,:));
    end

    % Write metadata
    % Assemble the metadata / properties of the TSeries which will be stored in
    % as a json string inside an attribute. 
    begonia.logging.log(1,"Writing metadata")
    metadata = struct;
    metadata.source = ts(i).source;
    metadata.name = ts(i).name;
    metadata.cycles = ts(i).cycles;
    metadata.channels = ts(i).channels;
    metadata.channel_names = ts(i).channel_names;
    metadata.frame_count = size(datCorrect, 3);
    metadata.img_dim = reshape(ts(i).img_dim,1,[]);
    metadata.dx = ts(i).dx;
    metadata.dy = ts(i).dy;
    metadata.dt = ts(i).dt;
    metadata.zoom = ts(i).zoom;
    metadata.frame_position_um = ts(i).frame_position_um;
    metadata.start_time = ts(i).start_time_abs;
    if isdatetime(metadata.start_time)
        metadata.start_time.Format = 'uuuu/MM/dd HH:mm:ss';
    end
    metadata.duration = metadata.frame_count * metadata.dt;
    metadata = jsonencode(metadata);
    h5writeatt(output_path,'/recording','name',ts(i).name);
    h5writeatt(output_path,'/recording','dx',ts(i).dx);
    h5writeatt(output_path,'/recording','dy',ts(i).dy);
    h5writeatt(output_path,'/recording','dt',ts(i).dt);
    h5writeatt(output_path,'/recording','json_metadata',metadata);

    % Set uuid.
    ts_new = begonia.scantype.find_scans(output_path);
    ts_new.dl_unique_id = ts(i).uuid;
end
