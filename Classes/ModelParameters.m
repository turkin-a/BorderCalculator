classdef ModelParameters  < ISingleton
    properties (Access = private)
        spanForFirstTimes
        minTraceAmpForFirstTimes
    end

    properties (Dependent, SetAccess = private)
        SpanForFirstTimes
        MinTraceAmpForFirstTimes
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