classdef(Abstract) ISeismicDataProvider < handle & matlab.mixin.Heterogeneous
    properties(Access = public, Abstract)
    end

    methods(Static, Abstract)
    end

    methods(Access = public, Abstract)
        seismicData = GetSeismicData();
    end
end