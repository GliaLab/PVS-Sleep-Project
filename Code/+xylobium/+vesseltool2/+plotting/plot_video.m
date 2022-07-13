function plot_video(ts, outdir ,frames)
    import xylobium.vesseltool2.measurement.*;

    if nargin < 3
        frames = 30:30:ts.frames_in_cycle-1;
    end
    
    if nargin < 2
        outdir = uigetdir();
    end

    if ~ts.has_var('vestool2_marker_array')
        error("TSeries has no markers"); 
    end

    % load previosu config from this tseries:
    markers = ts.load_var('vestool2_marker_array');
    
    for marker = markers
        fig = figure('position', [100, 100, 600,600]);
        
        fname = ts.name + " " + marker.name + ".mov";
        vwriter = VideoWriter(char(fullfile(outdir, fname)));
        open(vwriter);
        
        result_ch2 = analyse_frames(ts, 1, 1, 'valley-intercept', 60, marker, frames);
        result_ch3 = analyse_frames(ts, 1, 2, 'hill-intercept', 60, marker, frames);
        
        dist = ([result_ch2.distance_pix] - [result_ch3.distance_pix]) * ts.dx;


        % plot each frame:
        for i = 1:length(result_ch2)
            
            
            subplot(4,4,1);
            imagesc(result_ch2(i).mat_rotated)
            apply_style()
            
            
            subplot(4,4,2);
            imagesc(result_ch3(i).mat_rotated)
            apply_style()
            
            subplot(4,4,3);
            ref = imfuse(...
                result_ch2(i).mat_rotated ...
                , result_ch3(i).mat_rotated...
                , 'falsecolor' ...
                ,'Scaling','independent' ...
                , 'ColorChannels',[2 1 0]);
            imagesc(ref);
            apply_style();
            
            subplot(4,4,4);
            plot(result_ch2(i).linescan, 'color', 'green');
            yyaxis right;
            plot(result_ch3(i).linescan, 'color', 'red');
            %legend({"AE", "TRD"});
            
            ylims = ylim();
            ch2_dist = [result_ch2(i).intercept_y_left, result_ch2(i).intercept_y_right];
            line(ch2_dist, [ylims(2)*0.45 ylims(2)*0.45], 'color', 'green');
            
            ch3_dist = [result_ch3(i).intercept_y_left, result_ch3(i).intercept_y_right];
            line(ch3_dist, [ylims(2)*0.50 ylims(2)*0.50], 'color', 'red');
            
            % plot continuus line scans
            subplot(4,4,5:8);
            
            linescan_ch2 = cat(1, result_ch2(1:i).linescan)';
            linescan_ch3 = cat(1, result_ch3(1:i).linescan)';
            lsfused = imfuse(...
                linescan_ch2 ...
                , linescan_ch3...
                , 'falsecolor' ...
                ,'Scaling','independent' ...
                , 'ColorChannels',[2 1 0]);
            imagesc(lsfused);
            
            
            subplot(4,4,9:12);
            dist_ef = [result_ch2(1:i).distance_pix] * ts.dx;
            dist_trd = [result_ch3(1:i).distance_pix] * ts.dx;
            plot(dist_ef, 'color', 'green');
            hold on;
            plot(dist_trd, 'color', 'red');
            ylabel("μm");


            % plot distance:                 
            subplot(4,4,13:16);
            plot(dist(1:i), 'color', 'blue');
            ylabel("μm");
            title("AE - TRD")
            ylim([min(dist) * 0.90 max(dist) * 1.10]);
            
            suptitle(char(ts.name + " / " + marker.name)); 
            
            mat_frame = getframe(fig);
            vwriter.writeVideo(mat_frame);
            clf(fig);
            
        end
        
        close(vwriter);
        delete(fig);
    end
end


function apply_style()
    colormap(begonia.colormaps.turbo);
            
    xticks([]); 
    yticks([]);
end
