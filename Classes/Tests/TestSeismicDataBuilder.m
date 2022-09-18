classdef TestSeismicDataBuilder < handle
    properties (Access = public)
        numberOfSeismograms = 2;
        numberSamplesPerTrace = 10;
        numberSamplesPerSec = 1000;
        numberOfSensors = 3;
        sensorDistance = 50;
    end

    methods (Access = public)
        function seismicData = GetSeismicData(obj)
            seismicData = SeismicData();
            for i = 1:1:obj.numberOfSeismograms
                seismogram = GetSeismogram(obj);
                seismicData.Seismograms(i) = seismogram;
            end
            seismicData.NumberSamplesPerSec = obj.numberSamplesPerSec;
            seismicData.NumberOfSamplesPerTrace = obj.numberSamplesPerTrace;
        end

        function seismogram = GetSeismogram(obj)
            seismogram = Seismogram();
            traces(1:obj.numberOfSensors,1) = SeismicTrace();
            for i = 1:1:obj.numberOfSensors
                seismicTrace = GetSeismicTrace(obj);
                traces(i,1) = seismicTrace;
            end
            seismogram.SourceX = GetSourceX(obj);
            seismogram.SensorsX = GetSensorsX(obj);
            seismogram.Traces = traces;
        end

        function seismicTrace = GetSeismicTrace(obj)
            seismicTrace = SeismicTrace();
            samples = 1:1:obj.numberSamplesPerTrace;
            seismicTrace.Samples = samples;
        end

        function seismicDataForMatFile = GetSeismicDataForMatFile(obj)
            seismicDataForMatFile.SampPerTrace = obj.numberSamplesPerTrace;
            seismicDataForMatFile.discret = obj.numberSamplesPerSec;
            for i = 1:1:obj.numberOfSeismograms
                seismicDataForMatFile.Seis{1,i} = GetSeismogramForMatFile(obj);
                seismicDataForMatFile.mDetonX(1,i) = GetSourceX(obj);
                seismicDataForMatFile.mXd{1,i} = GetSensorsX(obj);
                seismicDataForMatFile.mZd{1,i} = GetSensorsZ(obj);
            end
        end
    end
    methods (Access = private)
        function seismogramForMatFile = GetSeismogramForMatFile(obj)
            seismogramForMatFile = zeros(obj.numberOfSensors,obj.numberSamplesPerTrace);
            for indexOfTrace = 1:1:obj.numberOfSensors
                trace = 1:1:obj.numberSamplesPerTrace;
                seismogramForMatFile(indexOfTrace,:) = trace;
            end
        end

        function sourcesX = GetSourcesX(obj)
            sourcesX = zeros(1,obj.numberOfSensors) + GetSourceX(obj);
        end

        function sourceX = GetSourceX(obj)
            sourceX = obj.sensorDistance;
        end

        function sensorsX = GetSensorsX(obj)
            sensorsX = (1:1:obj.numberOfSensors) * obj.sensorDistance;
        end

        function sensorsZ = GetSensorsZ(obj)
            sensorsZ = (1:1:obj.numberOfSensors) * 0;
        end
    end
end