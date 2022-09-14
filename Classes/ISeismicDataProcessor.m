classdef ISeismicDataProcessor < handle
    properties(Access = public, Abstract)
    end
   
    methods(Static, Abstract)
    end
    
    methods(Access = public, Abstract)
        obj = Calculate;
    end
end