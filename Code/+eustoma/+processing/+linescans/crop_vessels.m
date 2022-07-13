begonia.logging.set_level(1);

scans = eustoma.get_linescans(true);
scans = scans(scans.has_var('linescan_info'));
%%
for i = 1:length(scans)
    begonia.logging.log(1,'Trial %d/%d',i,length(scans));
    
    path = scans(i).load_var('path');
    path = strrep(path,'/',' ');
    path(1) = [];
    
    linescan_info = scans(i).load_var('linescan_info');
    
    begonia.logging.log(1,'Reading data');
    mat = scans(i).read();
    
    % Calculate how many frames should be merged to reach a sampling rate
    % at about 100 Hz. 
    merged_frames = round(linescan_info.fs / 100);

    % Approach a resolution at about 20 samples per micrometer. 
    merged_samples = round(1 / linescan_info.dx / 20);

    fs = linescan_info.fs / merged_frames;
    dx = linescan_info.dx * merged_samples;

    trial_id = scans(i).load_var('trial_id');
    trial_id_string = trial_id.trial_id;
    vessel_type = trial_id.vessel_type;
    trial_id = struct2table(trial_id);
    
    linescan_crop = scans(i).load_var('linescan_crop', []);
    
    if isempty(linescan_crop)
        %% Plot images of the linescans without crop.
        if linescan_info.channels == 1
            mat_red = squeeze(mat(1,:,:));
            % Merge frames to improve signal quality.
            begonia.logging.log(1,'Merging %d frames',merged_frames);
            mat_red = eustoma.util.merge_frames(mat_red,merged_frames);

            % Merge samples.
            begonia.logging.log(1,'Merging %d samples',merged_samples);
            mat_red = eustoma.util.merge_samples(mat_red,merged_samples);

            % Plot red
            fig = figure;
            fig.Position(3:4) = [1500,750];
            t = (0:size(mat_red,2)-1) / linescan_info.fs * merged_frames;
            imagesc(mat_red,'XData',t);
            xlabel('Time (seconds)');
            xlim([t(1),t(end)])
            set(gca,'FontSize',15)
            filename = fullfile(eustoma.get_plot_path,'Linescans without crop',trial_id_string + " Red.png");
            begonia.path.make_dirs(filename);
            exportgraphics(fig,filename);
            close(fig)
            
        elseif linescan_info.channels == 2
            mat_red = squeeze(mat(2,:,:));
            mat_green = squeeze(mat(1,:,:));
            % Merge frames to improve signal quality.
            begonia.logging.log(1,'Merging %d frames',merged_frames);
            mat_red = eustoma.util.merge_frames(mat_red,merged_frames);
            mat_green = eustoma.util.merge_frames(mat_green,merged_frames);

            % Merge samples.
            begonia.logging.log(1,'Merging %d samples',merged_samples);
            mat_red = eustoma.util.merge_samples(mat_red,merged_samples);
            mat_green = eustoma.util.merge_samples(mat_green,merged_samples);

            % Plot red
            fig = figure;
            fig.Position(3:4) = [1500,750];
            t = (0:size(mat_red,2)-1) / linescan_info.fs * merged_frames;
            imagesc(mat_red,'XData',t);
            xlabel('Time (seconds)');
            xlim([t(1),t(end)])
            set(gca,'FontSize',15)
            filename = fullfile(eustoma.get_plot_path,'Linescans without crop',trial_id_string + " Red.png");
            begonia.path.make_dirs(filename);
            exportgraphics(fig,filename);
            close(fig)

            % Plot green
            fig = figure;
            fig.Position(3:4) = [1500,750];
            t = (0:size(mat_green,2)-1) / linescan_info.fs * merged_frames;
            imagesc(mat_green,'XData',t);
            xlabel('Time (seconds)');
            xlim([t(1),t(end)])
            set(gca,'FontSize',15)
            filename = fullfile(eustoma.get_plot_path,'Linescans without crop',trial_id_string + " Green.png");
            begonia.path.make_dirs(filename);
            exportgraphics(fig,filename);
            close(fig)
        end
    else
        %% Linescan has crop
        N_vessels = size(linescan_crop,1);
        trial_id = repmat(trial_id,N_vessels,1);

        if linescan_info.channels == 1
            
            mat_red = squeeze(mat(1,:,:));
                
            % Offset to only use positive values, something weird with
            % the microscope.
            mat_red = mat_red - min(mat_red(:));
            
            vessel_red = cell(N_vessels,1);
            vessel_name = cell(N_vessels,1);
            vessel_fs = repmat(fs,N_vessels,1);
            vessel_dx = repmat(dx,N_vessels,1);

            for vessel_index = 1:N_vessels
                begonia.logging.log(1,'Cropping vessel %d/%d',vessel_index,N_vessels);
                st = linescan_crop(vessel_index,1);
                en = linescan_crop(vessel_index,2);
                mat_red_crop = mat_red(st:en,:);

                % Merge frames to improve signal quality.
                begonia.logging.log(1,'Merging %d frames',merged_frames);
                mat_red_crop = eustoma.util.merge_frames(mat_red_crop,merged_frames);

                % Merge samples.
                begonia.logging.log(1,'Merging %d samples',merged_samples);
                mat_red_crop = eustoma.util.merge_samples(mat_red_crop,merged_samples);

                mat_red_crop = int16(mat_red_crop);

                vessel_red{vessel_index} = mat_red_crop;

                vessel_name{vessel_index} = sprintf('%s %s %s',trial_id_string,vessel_type,trial_id.vessel_id);
            end
            vessel_name = categorical(vessel_name);

            vessels_red_raw = table(vessel_name,vessel_fs,vessel_dx,vessel_red, ...
                'VariableNames',{'vessel_name','vessel_fs','vessel_dx','vessel'});

            vessels_red_raw = cat(2,trial_id,vessels_red_raw);

            scans(i).save_var(vessels_red_raw);
        elseif linescan_info.channels == 2
            
            mat_red = squeeze(mat(2,:,:));
            mat_green = squeeze(mat(1,:,:));
                
            % Offset to only use positive values, something weird with
            % the microscope.
            mat_red = mat_red - min(mat_red(:));
            mat_green = mat_green - min(mat_green(:));
            
            vessel_red = cell(N_vessels,1);
            vessel_green = cell(N_vessels,1);
            vessel_name = cell(N_vessels,1);
            vessel_fs = repmat(fs,N_vessels,1);
            vessel_dx = repmat(dx,N_vessels,1);

            for vessel_index = 1:N_vessels
                begonia.logging.log(1,'Cropping vessel %d/%d',vessel_index,N_vessels);
                st = linescan_crop(vessel_index,1);
                en = linescan_crop(vessel_index,2);
                mat_red_crop = mat_red(st:en,:);
                mat_green_crop = mat_green(st:en,:);

                % Merge frames to improve signal quality.
                begonia.logging.log(1,'Merging %d frames',merged_frames);
                mat_red_crop = eustoma.util.merge_frames(mat_red_crop,merged_frames);
                mat_green_crop = eustoma.util.merge_frames(mat_green_crop,merged_frames);

                % Merge samples.
                begonia.logging.log(1,'Merging %d samples',merged_samples);
                mat_red_crop = eustoma.util.merge_samples(mat_red_crop,merged_samples);
                mat_green_crop = eustoma.util.merge_samples(mat_green_crop,merged_samples);

                mat_red_crop = int16(mat_red_crop);
                mat_green_crop = int16(mat_green_crop);

                vessel_red{vessel_index} = mat_red_crop;
                vessel_green{vessel_index} = mat_green_crop;

                vessel_name{vessel_index} = sprintf('%s %s %s',trial_id_string,vessel_type,trial_id.vessel_id);
            end
            vessel_name = categorical(vessel_name);

            vessels_red_raw = table(vessel_name,vessel_fs,vessel_dx,vessel_red, ...
                'VariableNames',{'vessel_name','vessel_fs','vessel_dx','vessel'});
            vessels_green_raw = table(vessel_name,vessel_fs,vessel_dx,vessel_green, ...
                'VariableNames',{'vessel_name','vessel_fs','vessel_dx','vessel'});

            vessels_red_raw = cat(2,trial_id,vessels_red_raw);
            vessels_green_raw = cat(2,trial_id,vessels_green_raw);

            begonia.logging.log(1,'Saving');
            scans(i).save_var(vessels_red_raw);
            scans(i).save_var(vessels_green_raw);
        end

        % Plot
        begonia.logging.log(1,'Plotting');
        if linescan_info.channels == 1
            mat = squeeze(mat(1, 1:merged_samples:end, 1:merged_frames:end));
        elseif linescan_info.channels == 2
            mat = squeeze(mat(2, 1:merged_samples:end, 1:merged_frames:end));
        end

        % Make an image indicationg which parts are ignored. 
        img_ignore = true(size(mat));
        for vessel_index = 1:N_vessels
            st = linescan_crop(vessel_index,1);
            en = linescan_crop(vessel_index,2);

            st = ceil(st / merged_samples);
            en = ceil(en / merged_samples);

            img_ignore(st:en,:) = false;
        end

        dim = size(mat);

        bounds = prctile(mat(1:10000),[8,92]);
        mat = mat - bounds(1);
        mat = mat / (bounds(2)-bounds(1));
        mat(mat < 0) = 0;
        mat(mat > 1) = 1;

        img = zeros(dim(1),dim(2),3);
        img(:,:,1) = mat;
        img(:,:,3) = img_ignore*0.7;


        fig = figure;
        fig.Position(3:4) = [1500,750];

        t = (0:size(mat,2)-1) / linescan_info.fs;
        imagesc(img,'XData',t);
        xlabel('Time (seconds)');

        xlim([t(1),t(end)])

        set(gca,'FontSize',15)

        % Save
        filename = fullfile(eustoma.get_plot_path,'Linescan Vessel Outlines',path);
        filename = [filename,'.png'];
        begonia.path.make_dirs(filename);
        warning off
        export_fig(fig,filename,'-png');
        warning on
        close(fig)
    end
end
begonia.logging.log(1,'Finished');
