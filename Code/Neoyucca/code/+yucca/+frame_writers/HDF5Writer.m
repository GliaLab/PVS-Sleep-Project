classdef HDF5Writer < yucca.frame_writers.FrameWriter
    %MULTIPNGWRITER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    properties (Access = private)
        
    end
    
    methods
        function write_2D_frame(obj, data)
            error('Not implemented');
        end
        
        function start_series(obj, ident)
            error('Not implemented');
        end
        
        function end_series(obj)
            error('Not implemented');
        end
    end
    
end

