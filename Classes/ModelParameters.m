classdef ModelParameters  < ISingleton
    properties (Access = private)
        spanForFirstTimes
        minTraceAmpForFirstTimes
        distanceForPointCalculation% = 1800
    end

    properties (Dependent, SetAccess = private)
        SpanForFirstTimes
        MinTraceAmpForFirstTimes
        DistanceForPointCalculation
    end

    methods
        function obj = ModelParameters()
        end
    end

    methods
        function spanForFirstTimes = get.SpanForFirstTimes(obj)
            spanForFirstTimes = obj.spanForFirstTimes;
        end
        function set.SpanForFirstTimes(obj, spanForFirstTimes)
            if ischar(spanForFirstTimes)
                spanForFirstTimes = str2double(spanForFirstTimes);
            end
            obj.spanForFirstTimes = spanForFirstTimes;
        end

        function minTraceAmpForFirstTimes = get.MinTraceAmpForFirstTimes(obj)
            minTraceAmpForFirstTimes = obj.minTraceAmpForFirstTimes;
        end
        function set.MinTraceAmpForFirstTimes(obj, minTraceAmpForFirstTimes)
            if ischar(minTraceAmpForFirstTimes)
                minTraceAmpForFirstTimes = str2double(minTraceAmpForFirstTimes);
            end
            obj.minTraceAmpForFirstTimes = minTraceAmpForFirstTimes;
        end

        function distanceForPointCalculation = get.DistanceForPointCalculation(obj)
            distanceForPointCalculation = obj.distanceForPointCalculation;
        end
        function set.DistanceForPointCalculation(obj, distanceForPointCalculation)
            if ischar(distanceForPointCalculation)
                distanceForPointCalculation = str2double(distanceForPointCalculation);
            end
            obj.distanceForPointCalculation = distanceForPointCalculation;
        end
    end

    methods (Access = public)
        function obj = SetSettings(obj, xmlData)
            fieldNames = fieldnames(xmlData);
            for i = 1:1:length(fieldNames)
                fieldName = fieldNames{i};
                obj.(fieldName) = xmlData.(fieldName);
            end
        end
        
    end

    methods(Static)
        function indexOfBegSensor = GetIndexOfBegSensor(seismogram)
            obj = ModelParameters.Instance();
            indexOfCentralSensor = seismogram.IndexOfCentralSensor;
            distanceBetwenTwoSensors = seismogram.GetDistanceBetwenTwoSensors();
            sensorsForPointCalculation = round(obj.distanceForPointCalculation / distanceBetwenTwoSensors);
            indexOfBegSensor = indexOfCentralSensor - sensorsForPointCalculation;
            if indexOfBegSensor < 1
                indexOfBegSensor = 1;
            end
        end
        function indexOfEndSensor = GetIndexOfEndSensor(seismogram)
            obj = ModelParameters.Instance();
            indexOfCentralSensor = seismogram.IndexOfCentralSensor;
            distanceBetwenTwoSensors = seismogram.GetDistanceBetwenTwoSensors();
            sensorsForPointCalculation = round(obj.distanceForPointCalculation / distanceBetwenTwoSensors);
            indexOfEndSensor = indexOfCentralSensor + sensorsForPointCalculation;
            if indexOfEndSensor > seismogram.NumberOfSensors
                indexOfEndSensor = seismogram.NumberOfSensors;
            end
        end

        function obj = Instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = ModelParameters();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
end