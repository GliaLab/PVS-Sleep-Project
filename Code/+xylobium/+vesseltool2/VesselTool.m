classdef VesselTool < xylobium.dledit.Editor
    %VESSELTOOLEDITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        tseries
        video_out_dir
    end
    
    methods
        function obj = VesselTool(tss, video_out_dir)
            import xylobium.vesseltool2.*;
            

            actions = VesselTool.get_default_actions();
            vars = {'name', 'start_time', 'vestool2_marker_array', 'vestool2_results', 'vestool2_video'};
            obj = obj@xylobium.dledit.Editor(tss, actions, vars);
        
            obj.tseries = tss;
            obj.video_out_dir = video_out_dir;
            
        end
        
    end
    
    methods (Static)
        
        function actions = get_default_actions()
            import xylobium.dledit.*;
            import xylobium.vesseltool2.actions.*;

            ac_open_matview_ch2 = Action(...
                'Matview CH2', @(d, m, e) begonia.util.matview(d.get_mat(1,1)), false, true, 'control-shift-c');

            ac_open_matview_ch3 = Action(...
                'Matview CH3', @(d, m, e) begonia.util.matview(d.get_mat(1,2)), false, true, 'control-shift-c');

            ac_open_ctool = Action(...
                'Config tool', @(d, m, e) xylobium.vesseltool2.action.open_configtool(d), false, true, 'control-shift-c');

            ac_full_analysis = Action(...
                'Analyse', @(d, m, e) xylobium.vesseltool2.action.analyse(d, m), true, false, 'control-shift-a');

            ac_video_trace = Action(...
                'Generate video', @(d, m, e) xylobium.vesseltool2.action.generate_video(d, m, e), true, false);
            
             ac_video_output_dir = Action(...
                'Set video output dir', @(d, m, e) set_video_outputdir(d, m, e), false, false);
            
            ac_plot = Action(...
                'Plot results', @(d, m, e) xylobium.vesseltool2.action.plot_markers(d), true, false, 'control-shift-r');
            
            ac_plot_results_dist = Action(...
                'View results (dist)', @(d, m, e) plot_results_dist(d), true, false, 'control-shift-z');

            ac_export_table = Action(...
                'Export table...', @(d, m, e) export_table(d), false, true, 'control-shift-t');

            
            actions = [ ...
                ac_open_matview_ch2 ...
                ac_open_matview_ch3 ...
                ac_open_ctool ...
                ac_full_analysis ...
                ac_plot ...
                ac_video_trace];
        end
    end
end

