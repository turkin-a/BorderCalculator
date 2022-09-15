classdef SeismicData < handle & matlab.mixin.Copyable
    properties (Access = private)
        seismograms cell = []
        countOfSeismograms double {mustBeNonnegative(countOfSeismograms)}
        samplingPerSec double {mustBeNonnegative(samplingPerSec)}
        samplingPerTrace double {mustBeNonnegative(samplingPerTrace)}
    end

    properties (Dependent)
        Seismograms
        CountOfSeismograms
        SamplingPerSec
        SamplingPerTrace
    end

    methods
        function set.SamplingPerSec(obj, samplingPerSec)
            obj.samplingPerSec = samplingPerSec;
        end
        function samplingPerSec = get.SamplingPerSec(obj)
            samplingPerSec = obj.samplingPerSec;
        end

        function set.SamplingPerTrace(obj, samplingPerTrace)
            obj.samplingPerTrace = samplingPerTrace;
        end
        function samplingPerTrace = get.SamplingPerTrace(obj)
            samplingPerTrace = obj.samplingPerTrace;
        end

        function set.Seismograms(obj, seismograms)
            obj.seismograms = seismograms;
            obj.countOfSeismograms = length(seismograms);
        end
        function seismograms = get.Seismograms(obj)
            seismograms = obj.seismograms;
        end

        function countOfSeismograms = get.CountOfSeismograms(obj)
            countOfSeismograms = obj.countOfSeismograms;
        end
    end

    methods (Access = public)
        % Нормализовать сейсмические данные
        function obj = Normalization(obj, sizeOfHalfWindow)
            for i = 1:1:length(obj.Seismograms)
                seismogram = obj.Seismograms{i};
                                
                seismogram.Normalization(sizeOfHalfWindow);
                firstTimes = seismogram.FirstTimes;
                obj.seismograms{i} = seismogram;
            end
        end
    end
end

