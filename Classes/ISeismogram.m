classdef ISeismogram < handle

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