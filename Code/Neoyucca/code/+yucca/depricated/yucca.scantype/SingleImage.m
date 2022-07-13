classdef SingleImage < yucca.scantype.PrairieOutput
    %LINESCAN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = SingleImage(path)
            obj@yucca.scantype.PrairieOutput(path);

            % assert we are a linescan:
            assert(strcmp(obj.type, 'Single'), ...
                    'begonia:invalid_stack:not_singleimage_sequence_type', ...
                    'Not a single image according to type');
        end
    end
    
end

