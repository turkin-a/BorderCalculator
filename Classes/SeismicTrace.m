classdef SeismicTrace < handle & matlab.mixin.Copyable
    properties (Access = private)
        samples double = []
    end

    properties (Dependent)
        Samples
        CountSamplesPerTrace
    end

    methods
        function set.Samples(obj, samples)
            obj.samples = samples;
        end
        function samples = get.Samples(obj)
            samples = obj.samples;
        end
        
        function countSamplesPerTrace = get.CountSamplesPerTrace(obj)
            countSamplesPerTrace = length(obj.samples);
        end
    end

    methods (Access = public)
        function obj = SeismicTrace()
        end
    end
    
    methods (Access = private)
    end
end

