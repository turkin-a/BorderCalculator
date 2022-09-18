classdef Seismogram < ISeismogram & matlab.mixin.Copyable
    properties (Access = private)
        isFirstTimesCalculated = false
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

        function firstTimes = get.FirstTimes(obj)
            firstTimes = obj.firstTimes;
        end

        % Рассчитать первые вступления
        function obj = CalculateFirstTimes(obj, span, minTraceAmplitude)
            indexOfSeismogramCenter = GetIndexOfSeismogramCenter(obj);
            newFirstTimes = zeros(1, obj.NumberOfSensors);
            for indexOfTrace = 1:1:obj.NumberOfSensors
                trace = obj.Traces(indexOfTrace);
                newFirstTimes(indexOfTrace) = trace.CalculateFirstTime(span, minTraceAmplitude);
            end
            obj.firstTimes = SmoothFirstTimes(obj, newFirstTimes, indexOfSeismogramCenter);
            obj.isFirstTimesCalculated = true;
        end

        % Найти номер датчика с наименьшим удалением от источника
        function indexOfSeismogramCenter = GetIndexOfSeismogramCenter(obj)
            Li = abs(obj.sensorsX - obj.sourceX);
            indexOfSeismogramCenter = find(min(Li) == Li);
            indexOfSeismogramCenter = indexOfSeismogramCenter(1);
        end

        % Массив максимальных разрешенных растояний от источника до дальнего датчика
        function maxDistance = GetMaximumAllowableDistanceFromSource(obj)
            indexOfSeismogramCenter = obj.GetIndexOfSeismogramCenter();
            leftDistance = indexOfSeismogramCenter-1;
            rigthDistance = obj.numberOfSensors - indexOfSeismogramCenter;
            maxDistance = min([leftDistance rigthDistance]);
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

    methods(Access = private)
        % Удаление выбросов (сглаживание) массива времен первых вступлений
        function firstTimes = SmoothFirstTimes(obj, firstTimes, indexOfCenter)
            leftFirstTimes = firstTimes(1:indexOfCenter);
            leftFirstTimes = SmoothOneSideFirstTimes(obj, leftFirstTimes);
            
            rightFirstTimes = firstTimes(indexOfCenter:end);
            rightFirstTimes = SmoothOneSideFirstTimes(obj, rightFirstTimes);
            
            firstTimes(1:indexOfCenter-1) = leftFirstTimes(1:end-1);
            firstTimes(indexOfCenter+1:end) = rightFirstTimes(2:end);
        end
        
        % Удаление выбросов (сглаживание) массива времен первых вступлений
        % с одной стороны относительно центра
        function firstTimes = SmoothOneSideFirstTimes(obj, firstTimes)
            w = round(30+length(firstTimes)/1.5);
            x = 1:length(firstTimes);
            pn1 = polyfit(x, firstTimes, 1);
            y1 = polyval(pn1, x);
            diffValue = abs(firstTimes - y1);
            y = y1;
            while max(diffValue) > w
                ind = find(max(diffValue) == diffValue);
                i = ind(1);
                newValue = round(y(i)-2);
                if newValue < 1
                    newValue = round(y(i));
                    if newValue < 1
                        newValue = firstTimes(i);
                    end
                end
                curDiffValue = diffValue(i);
                if curDiffValue > w
                    firstTimes(i) = newValue;
                end
                pn1 = polyfit(x, firstTimes, 1);
                y1 = polyval(pn1, x);
                diffValue1 = abs(firstTimes - y1);
                diffValue = diffValue1;
                y = y1;
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

