classdef Seismogram < ISeismogram & matlab.mixin.Copyable
    properties (Access = private)
        sourceX   double = []
        sensorsX double = []
        seismicTraces cell = []
        countSensors double = 0
        countSamplesPerTrace double = 0
        firstTimes double = []
    end

    properties (Dependent)
        SourceX
        SensorsX
        Traces 
        CountSensors
        CountSamplesPerTrace
        FirstTimes
    end

    methods
        function set.SourceX(obj, sourceX)
            obj.sourceX = sourceX;
        end
        function sourceX = get.SourceX(obj)
            sourceX = obj.sourceX;
        end

        function set.SensorsX(obj, sensorsX)
            obj.sensorsX = sensorsX;
        end
        function sensorsX = get.SensorsX(obj)
            sensorsX = obj.sensorsX;
        end

        function set.Traces(obj, traces)
            obj.seismicTraces = traces;
            obj.countSensors = length(traces);
            obj.countSamplesPerTrace = obj.seismicTraces{1}.CountSamplesPerTrace;
        end        
        function seismicTraces = get.Traces(obj)
            seismicTraces = obj.seismicTraces;
        end

        function countSensors = get.CountSensors(obj)
            countSensors = obj.countSensors;
        end

        function countSamplesPerTrace = get.CountSamplesPerTrace(obj)
            countSamplesPerTrace = obj.countSamplesPerTrace;
        end

        function set.FirstTimes(obj, firstTimes)
            obj.firstTimes = firstTimes;
        end
        function firstTimes = get.FirstTimes(obj)
            firstTimes = obj.firstTimes;
        end
    end

    methods (Static)
        % Создание объекта Seismogram с параметрами 
        % seisData (трассы в двумерном массиве)
        % sourceX, sensorsX
        function seismogram = BuildSeismogram(seisData, sourceX, sensorsX)
            seismogram = Seismogram();
            countSensors = size(seisData,1);
            traces = cell(countSensors, 1);
            for j = 1:1:countSensors
                trace = seisData(j,:);
                seismicTrace = SeismicTrace();
                seismicTrace.Samples = trace;
                traces{j} = seismicTrace;
            end
            seismogram.SourceX = sourceX;
            seismogram.SensorsX = sensorsX;
            seismogram.Traces = traces;
        end
    end

    methods (Access = public)
    end
end

