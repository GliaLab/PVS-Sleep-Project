classdef LineConfigTool < handle
    %VALLEYDISTANCESETUPVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fig
        fig_hidden % for frame analyser
        
        marker_array
        
        % matrix and stck:
        tseries
        mat
        
        channel
        cycle
        
        % axis:
        ax_zoomed;
        ax_valley;
        ax_timeseries;
        ax_overview;
        ax_hidden % for frame analyser
        
        % event handles to be deleted when figure is closed:
        ev_frame_listener;
        ev_marker_list_changed_listener;
        ev_marker_changed_listener;
        
        % timer to update only at max 1/2 Hz and avoid choppy line dragging
        % on events etc.
        update_timer
        timer_process_tick % the tick being processed, or last processed
        timer_newest_tick % the most recent 
        
        % struct to associate imdistline with marker:
        marker_lines
        line_selected
        marker_selected
        marker_selected_index
        
        % analyser object to perform analysis on mat for previews
        analyzer
        
        % matrix of current frame and reference frame:s
        frame_cur
        frame_ref
        frames_samples
        
        % flag for showing or hiding names
        show_names
    end
    
    properties (Transient)
        % current frame from stack of zoomed view and preview graph:
        current_frame_nr
    end
    
    properties (Access = private)
        current_frame_nr_;
    end
    
    events
       on_marker_added % fired when a marker is added
       on_marker_list_changed % fired when the list of markers is changed
    end
    
    methods
        function obj = LineConfigTool(tseries)
            obj.tseries = tseries;
            
            % simply use defaults for now:
            obj.channel = 1;
            obj.cycle = 1;
            
            obj.mat = obj.tseries.get_mat(obj.cycle, obj.channel);
            obj.frames_samples = [];
            
            % setup:
            obj.marker_lines = struct('line',{},'marker',{});
            obj.update_timer = timer('ExecutionMode', 'fixedDelay', 'Period', 0.1);
            obj.update_timer.TimerFcn = @(~,~) obj.handle_timer();
            obj.timer_newest_tick = 1;
            obj.timer_process_tick = 0; % forces redraw on start
            
            obj.show_names = true;
            
            obj.setup_graphs();
            obj.setup_reference_image();

            % for debugging:
            obj.load_marker_array();
            
            obj.current_frame_nr = 1;
            start(obj.update_timer);
            
        end
        
        % creates axis of the subplot:
        function setup_graphs(obj)
            obj.fig = figure();
            obj.fig.Position = obj.fig.Position * 1.7;
            obj.fig.Name = 'Vessel picker';
            obj.fig.MenuBar = 'none';
            obj.fig.ToolBar = 'figure';
            obj.fig.CloseRequestFcn = @(~,~) obj.close();
            obj.fig.Color = 'white';
            
            % overview of current tseries:
            subplot(2,2,2);
            plot(1);
            obj.ax_overview = obj.fig.CurrentAxes();
            
            
            % selection area:
            subplot(2,2,1);
            plot(1);
            obj.ax_zoomed = obj.fig.CurrentAxes();
            
            % overview of current tseries:
            subplot(2,2,3);
            plot(1);
            obj.ax_timeseries = obj.fig.CurrentAxes();
            
            % view of current linescan valley:
            subplot(2,2,4);
            plot(1);
            obj.ax_valley = obj.fig.CurrentAxes();
            
            % events:
            obj.fig.KeyPressFcn = @(s,e) obj.handle_keyboard(s,e);
            
            % hidden figure for analyser:
            obj.fig_hidden = figure('Visible', 'off');  
            plot(1);
            obj.ax_hidden = obj.fig_hidden.CurrentAxes();
        end

        
        % get or create reference image (also used to get locked means):
        function setup_reference_image(obj)
            % FIXME: should use f0 image!
            obj.frame_ref = xylobium.vesseltool2.utility.get_multichannel_reference_img(obj.tseries);
            
            himg = imagesc(obj.frame_ref, 'parent', obj.ax_overview);
            title(obj.ax_overview, 'Line selector')
            himg.ButtonDownFcn = @(s,ev) disp('click');
        end
        
        
        % handle the 
        function handle_keyboard(obj, ~, ev)
            code = xylobium.shared.keyboard_event_to_str(ev);
            
            switch (code)
                
                case 'shift-a'
                    obj.new_marker_line('artery');
                    
                case 'shift-v'
                    obj.new_marker_line('vein');
                    
                case 'shift-c'
                    obj.new_marker_line('capillary'); 
                    
                case 'shift-u'
                    obj.new_marker_line('unknown'); 
                    
                case 'shift-n'
                    obj.toggle_names();
                    
                case 'backspace'
                    obj.remove_last_line();
                    
                case 'shift-s'
                    obj.save_marker_array();
                    
                otherwise
                    disp(code);
            end
        end
        
        % executes the timer:
        function handle_timer(obj)
            if obj.timer_process_tick < obj.timer_newest_tick
                try
                    obj.update_preview();
                    obj.timer_process_tick = obj.timer_newest_tick;
                catch err
                    disp('Timer error:')
                    err.stack.name
                end
            end
        end
        
        % handler for the line change om imdistlines:
        function handle_line_change(obj, line)
            
            % make sure the object's selected marker is the one we have:
            obj.marker_selected = [];
            ml_idx = find([obj.marker_lines.line] == line);
            
            obj.marker_selected = obj.marker_lines(ml_idx).marker;
            obj.line_selected = line;
            
            % update title with seleted line
            obj.fig.Name = obj.marker_selected.name + " (vtool v2)";
            obj.fig.NumberTitle = 'off';
            
            obj.update_markers();
            obj.invalidate_gui();
        end
        
        
        % changes visibility of line names:
        function toggle_names(obj)
            obj.show_names = ~ obj.show_names;
            for line = obj.marker_lines
                line.line.setLabelVisible(obj.show_names);
            end
            
            %obj.invalidate_gui();
        end
        
        
        function invalidate_gui(obj)
            obj.timer_newest_tick = obj.timer_newest_tick + 1;
        end
        
        
        
        % getter and setter for current frame:
        function set.current_frame_nr(obj, fnr)
            obj.current_frame_nr_ = fnr;
            obj.frame_cur = obj.mat(:,:,fnr);
            obj.invalidate_gui();
        end
        
        function fnr = get.current_frame_nr(obj)
            fnr = obj.current_frame_nr_;
        end
        
        % creates a new marker of given type:
        function new_marker_line(obj, type)
            marker = xylobium.vesseltool2.VesselScanline(type);
            obj.add_marker_line(marker);
        end
        
        
        % adds a marker with an associated imdistline, or creats a new
        % marker if no paramter is given:
        function add_marker_line(obj, marker)
            

            ml_idx = length(obj.marker_lines) + 1;
            line = imdistline(obj.ax_overview);
            line.setLabelVisible(obj.show_names);
            line.setLabelTextFormatter(marker.name); 
            
            obj.marker_lines(ml_idx) = struct('marker', marker, 'line', line);
            
            line.setPosition( ...
                [marker.start_point(1) marker.end_point(1)] ...
                , [marker.start_point(2) marker.end_point(2)]);
            
            % event to update preview when the line is changed:
            line.addNewPositionCallback(@(~) obj.handle_line_change(line));
            
            % set color according to type:
            if marker.vessel_type == "artery"
                line.setColor('red');
            elseif marker.vessel_type == "vein"
                line.setColor('blue');
            else
                line.setColor('yellow');
            end
            
            notify(obj, 'on_marker_added');
            notify(obj, 'on_marker_list_changed');
        end
        
        
        function remove_last_line(obj)
            if isempty(obj.marker_selected)
                obj.fig.Name = "(no marker selected to delete)";
                beep;
                return;
            end
            
            rm_idx = find([obj.marker_lines.marker] == obj.marker_selected)
            
            ml = obj.marker_lines(rm_idx);
            line = ml.line;
            delete(line);
            
            obj.marker_lines(rm_idx) = [];
            obj.marker_selected = [];
            obj.line_selected = [];
            
            obj.update_markers();
        end
     
        
        % updates the preview and valley data of 
        function update_preview(obj)
            import xylobium.vesseltool2.measurement.*;
            
            obj.clean_invalid_markers();
            
            % skip if no marker selected:
            if isempty(obj.line_selected) || isempty(obj.marker_selected)
               return; 
            end
            
            % draw 
            marker = obj.marker_selected;
            obj.update_markers();
            
            % analyse two frames (red and green):
            result_ch2 = analyse_frame(obj.tseries, 1, 1, 'valley-intercept', 60, marker);
            result_ch3 = analyse_frame(obj.tseries, 1, 2, 'hill-intercept', 60, marker);
            
            % analyse current frame
%             [diam, diam_lrd, diam_l, diam_hp, aut, chmean, lscan, means, mat_rot, mat_aut, peaks, peak_interceps] = ...
%                 xylobium.vesseltool.vdist.analyse_frame( ...
%                     obj.frame_ref, xs, ys, obj.ax_hidden, 3, [100 100]);
            
            % print the zoomed preview:
            hold(obj.ax_zoomed, 'off');
            imagesc(obj.ax_zoomed, result_ch2.mat_rotated);
            xlimits = xlim(obj.ax_zoomed);
            ylimits = ylim(obj.ax_zoomed);
            refline_x = floor(xlimits(2) / 2);
            line(obj.ax_zoomed, [refline_x refline_x], ylimits, 'LineWidth',5, 'color', [.5 .5 .5 .5]);
            title(obj.ax_zoomed, marker.name + " CH2");
            colormap(obj.ax_zoomed, begonia.colormaps.turbo);
            
            hold(obj.ax_timeseries, 'off');
            imagesc(obj.ax_timeseries, result_ch3.mat_rotated);
            xlimits = xlim(obj.ax_timeseries);
            ylimits = ylim(obj.ax_timeseries);
            refline_x = floor(xlimits(2) / 2);
            line(obj.ax_timeseries, [refline_x refline_x], ylimits, 'LineWidth',5, 'color', [.5 .5 .5 .5]);
            title(obj.ax_timeseries, marker.name + " CH3");
            colormap(obj.ax_timeseries, begonia.colormaps.turbo);
            
            
%             % update complex graphs:
            obj.update_lscan_graph(result_ch2, result_ch3);
%             
%             % keep means as the locked means:
%             obj.marker_selected.locked_means = means;
        end
        
        
        function update_lscan_graph(obj, result_ch2, result_ch3)
            
            ax = obj.ax_valley;
            cla(ax);
            
            scan_ln = length(result_ch2.linescan);
            
            plot(ax, result_ch2.linescan, 'color', 'green', 'linewidth', 1.5);
            hold(ax, 'on');
            plot(ax, result_ch3.linescan, 'color', 'red', 'linewidth', 1.5);
            hold(ax, 'off');
            grid(ax, 'on');
            xlim(ax, [0 length(result_ch3.linescan())]);
            
            mid = floor(scan_ln/2);

            % draw line on mid:
            ylims = ylim(ax);
            line(ax, [mid, mid], [ylims(1) ylims(2)]);
            
            % mark intercepts:
            ch2_dist = [result_ch2.intercept_y_left, result_ch2.intercept_y_right];
            line(ax, ch2_dist, [ylims(2)*0.45 ylims(2)*0.45], 'color', 'green');
            
            ch3_dist = [result_ch3.intercept_y_left, result_ch3.intercept_y_right];
            line(ax, ch3_dist, [ylims(2)*0.50 ylims(2)*0.50], 'color', 'red');
            
           
            title(ax, 'Distance measurement');
        end

        
        % constructs a config object based on the current markers:
        function markers = get.marker_array(obj)
            % get the markers for each imdistline, and reload the values
            % for that marker:
            obj.clean_invalid_markers();
            obj.update_markers();
            
%             for ml = obj.marker_lines
%                 
% %                 % update the marker's position to match line:
% %                 m = ml.marker;
% %                 lpos = ml.line.getPosition();
% %                 m.start_point = [lpos(1,1), lpos(1,2)];
% %                 m.end_point = [lpos(2,1), lpos(2,2)];
% %                 
%                 % add marker details from imdisline:
%                 conf.markers(end + 1) = ml.marker;
%             end
            markers = [obj.marker_lines.marker];
        end
        
        % saves the current config to the tseries:
        function save_marker_array(obj) 
            obj.clean_invalid_markers()
            obj.update_markers();
            obj.tseries.save_var('vestool2_marker_array', obj.marker_array);
            
            obj.fig.Name = ['Saved markers' char(datetime)];
        end
        
        
        % loads a previouslky saved config, if present
        function loaded = load_marker_array(obj)
            % simply return false if no config is loaded. If no markers are
            % loaded, the tool will add some new lines in the costructor:
            loaded = false;
            if ~obj.tseries.has_var('vestool2_marker_array')
               return; 
            end
            
            % load previosu config from this tseries:
            markers = obj.tseries.load_var('vestool2_marker_array');
            
            % load markers from config:
            for marker = markers
                obj.add_marker_line(marker);
            end
            
            % this means markers have changed:
            notify(obj, 'on_marker_list_changed');
        end
        
        
        % update all markers with their references line's position:
        function update_markers(obj)
            
            for i = 1:length(obj.marker_lines)
                ml = obj.marker_lines(i);
                
                % update the marker's position to match line:
                m = ml.marker;
                lpos = ml.line.getPosition();
                m.start_point = [lpos(1,1), lpos(1,2)];
                m.end_point = [lpos(2,1), lpos(2,2)];
                m.angle = 90 - ml.line.getAngleFromHorizontal();
                
                % update marker val
                obj.marker_lines(i).marker = m;
            end
        end
        
        % there is no easy way to detect if imdistline is deleted AFAIK, so
        % this function cleans the list and is called when an update list
        % is needed:
        function clean_invalid_markers(obj)
            pre_count = length(obj.marker_lines);
            valids = arrayfun(@(mlc) isvalid(mlc.line), obj.marker_lines);
            obj.marker_lines = obj.marker_lines(valids);
            
            if pre_count ~= length(obj.marker_lines)
                notify(obj, 'on_marker_list_changed');
            end
        end

        
        % clears event listeners to prevent actions on deleted objects
        function close(obj, save)
            if nargin < 2
                save = true;
            else
                save = false;
            end
            if save
                disp('Auto-saving on close');
                obj.save_marker_array();
            end
            
            % clean up timer and objects:
            stop(obj.update_timer)
            delete(obj.update_timer);
            delete(obj.fig_hidden);
            delete(obj.fig);
            delete(obj.ev_frame_listener);
            delete(obj.ev_marker_changed_listener);
            delete(obj.ev_marker_list_changed_listener);
            delete(obj);
        end
        

    end
end








