classdef CombiningReader
    %READERCOMBINER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        readers
    end
    
    methods
        function obj = CombiningReader(varargin)
            obj.readers = varargin;
        end
        
            
        % override for builtin size function:
        function n = size(obj, d)
            size_vec = [0 0 0];
            for reader_cell = obj.readers
                reader = reader_cell{:};
                size_vec(1) = size_vec(1) + size(reader, 1);
                size_vec(2) =  size(reader, 2);
                size_vec(3) = size(reader, 3);
            end
            
            if nargin < 2
               n = size_vec;
            else
                n = size_vec(d);
            end
        end
        
        % override for allow using the reader with indexes:
        function result = subsref(obj, indicies)
            if(~strcmp(indicies(1).type,'()'))
                % we only want to deal with indexing, and pass other stuff
                % onto the builtin subsref function. This prevents this
                % modification from interfering with e.g. dot-notation.
                result = builtin('subsref', obj, indicies);
            else
                result = uint16([]);
                if length(indicies.subs) < 3
                    error('Reader requires three indexes')
                end 
                
                result = [];
                
                % grab frames and extract subarea:
                zr = indicies.subs{3};
                
                for reader_cell = obj.readers
                    reader = reader_cell{:};
                    submat = reader(:,:,zr);
                    result = horzcat(result, submat);
                end
            end
        end
        

    end
end

