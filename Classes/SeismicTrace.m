classdef SeismicTrace < handle & matlab.mixin.Copyable
    properties (Access = private)
        samples (1,:) double = []
    end

    properties (Dependent)
        Samples
        NumberOfSamplesPerTrace
    end

    methods
        function set.Samples(obj, samples)
            obj.samples = samples;
        end
        function samples = get.Samples(obj)
            samples = obj.samples;
        end

        function numberOfSamplesPerTrace = get.NumberOfSamplesPerTrace(obj)
            numberOfSamplesPerTrace = length(obj.samples);
        end
    end

    methods (Access = public)
        function obj = SeismicTrace()
        end
    end

    methods (Access = private)
    end
end

