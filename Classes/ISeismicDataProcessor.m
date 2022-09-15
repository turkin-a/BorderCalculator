classdef(Abstract) ISeismicDataProcessor < handle & matlab.mixin.Heterogeneous
    properties(Access = public, Abstract)
    end

    methods(Static, Abstract)
    end

    methods(Access = public, Abstract)
        obj = Calculate;
    end

    methods(Static, Access = public)
    end
end