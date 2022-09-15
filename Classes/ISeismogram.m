classdef(Abstract) ISeismogram < handle & matlab.mixin.Heterogeneous

    properties (Dependent, Abstract)
        SourceX
        SensorsX
        Traces 
        CountSensors
        CountSamplesPerTrace
        FirstTimes
    end

    methods (Abstract, Static)
        seismogram = BuildSeismogram();
    end
end