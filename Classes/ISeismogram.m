classdef(Abstract) ISeismogram < handle & matlab.mixin.Heterogeneous

    properties (Dependent, Abstract)
        SourceX
        SensorsX
        Traces
        NumberOfSensors
        NumberOfSamplesPerTrace
        FirstTimes
    end

    methods (Abstract, Static)
        seismogram = BuildSeismogram();
    end
end