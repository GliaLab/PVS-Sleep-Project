classdef TSeries < yucca.scantype.PrairieOutput
    %LINESCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = TSeries(path)
            obj@yucca.scantype.PrairieOutput(path)
            
            % assert we are a linescan:
            assert(strcmp(obj.type, 'TSeries Timed Element'), ...
                    'begonia:invalid_stack:not_tseries_sequence_type', ...
                    'Not a tseries according to type');
               
        end
    end
    
end

