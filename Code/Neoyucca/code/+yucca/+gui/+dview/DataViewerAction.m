% cannot use structs as they are copy-on-pass rather than pointers ):

classdef DataViewerAction < handle
    %DATAVIEWERACTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Title
        Runcheck
        Callback
        Button
        IsSpacer
        IsLabel
    end
    
    methods
        function obj = DataViewerAction(title)
           obj.Title = title; 
           obj.IsSpacer = 0;
           obj.IsLabel = 0;
        end
        
    end
    
end

