classdef Seismogram < ISeismogram & matlab.mixin.Copyable
    properties (Access = private)
        sourceX (1,1) double
        sensorsX (1,:) double = []
        seismicTraces (:,1) SeismicTrace
        numberOfSensors (1,1) double = 0
        numberOfSamplesPerTrace (1,1) double = 0
        firstTimes (1,:) double = []
    end

    properties (Dependent)
        SourceX
        SensorsX
        Traces
        NumberOfSensors
        NumberOfSamplesPerTrace
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
            obj.numberOfSensors = size(obj.seismicTraces,1);
            obj.numberOfSamplesPerTrace = obj.seismicTraces(1).NumberOfSamplesPerTrace;
        end
        function seismicTraces = get.Traces(obj)
            seismicTraces = obj.seismicTraces;
        end

        function countSensors = get.NumberOfSensors(obj)
            countSensors = obj.numberOfSensors;
        end

        function numberOfSamplesPerTrace = get.NumberOfSamplesPerTrace(obj)
            numberOfSamplesPerTrace = obj.numberOfSamplesPerTrace;
        end

        function set.FirstTimes(obj, firstTimes)
            obj.firstTimes = firstTimes;
        end
        function firstTimes = get.FirstTimes(obj)
            firstTimes = obj.firstTimes;
        end
    end


    methods(Access = protected)
      % Override copyElement method:
      function cpObj = copyElement(obj)
         % Make a shallow copy of all four properties
         cpObj = copyElement@matlab.mixin.Copyable(obj);
         % Make a deep copy of the seismicTraces object
         for i = 1:1:length(obj.seismicTraces)
             cpObj.seismicTraces(i) = copy(obj.seismicTraces(i));
         end
      end
   end

    methods (Static)
        function seismogram = BuildSeismogram(seisData, sourceX, sensorsX)
            seismogram = Seismogram();
            numberOfSensors = length(sensorsX);
            traces(1:numberOfSensors,1) = SeismicTrace();
            for j = 1:1:numberOfSensors
                trace = seisData(j,:);
                seismicTrace = SeismicTrace();
                seismicTrace.Samples = trace;
                traces(j,1) = seismicTrace;
            end
            seismogram.SourceX = sourceX;
            seismogram.SensorsX = sensorsX;
            seismogram.Traces = traces;
        end
    end
end

