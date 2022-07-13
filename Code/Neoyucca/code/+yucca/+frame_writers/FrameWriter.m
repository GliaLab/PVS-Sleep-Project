classdef (Abstract) FrameWriter < handle
    %FRAMEWRITER Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function write_2D_frame(data)
            error('FrameWriter subclass needs to overwrite write_2D_frame()');
        end
        
        function start_series(ident)
            error('FrameWriter subclass needs to overwrite start_series()');
        end
        
        function results = end_series(ident)
            error('FrameWriter subclass needs to overwrite end_series()');
        end
    end
    
end

