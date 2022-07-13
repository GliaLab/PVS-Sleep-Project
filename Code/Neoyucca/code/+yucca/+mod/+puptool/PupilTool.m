classdef PupilTool < xylobium.dledit.Editor
    %VESSELTOOLEDITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        trials
        video_out_dir
    end
    
    methods
        function obj = PupilTool(trials, video_out_dir)
            import yucca.mod.puptool.*;
            

            actions = PupilTool.get_default_actions();
            vars = {'name', 'start_time', '!puptrack_valid',  'puptrack_config', 'puptrack_data', 'puptrack_video'};
            obj = obj@xylobium.dledit.Editor(trials, actions, vars);
        
            obj.trials = trials;
            obj.video_out_dir = video_out_dir;
            
        end
        
    end
    
    methods (Static)
        
        function actions = get_default_actions()
            import xylobium.dledit.*;
            import yucca.mod.puptool.action.*;

            ac_conf = Action(...
                'Configure', @(d, m, e) configure_pup(d), false, false, 'control-shift-c');
            
            ac_trace = Action(...
                'Trace', @(d, m, e) trace_pup(d), true, false, 'control-shift-t');
            
            ac_video = Action(...
                'Generate video', @(d, m, e) generate_video(d, e), true, false, 'control-shift-v');
            
            actions = [ ...
                ac_conf ac_trace ac_video];
        end
    end
end

