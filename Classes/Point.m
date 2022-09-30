classdef Point
    properties (Access = private)
        indexOfSensor (1,1) double = 0
        time (1,1) double = 0
    end

    properties (Dependent)
        IndexOfSensor
        Time
    end

    methods
        function obj = Point(indexOfSensor, time)
            obj.indexOfSensor = indexOfSensor;
            obj.time = time;
        end

        function obj = set.IndexOfSensor(obj, indexOfSensor)
            obj.indexOfSensor = indexOfSensor;
        end
        function indexOfSensor = get.IndexOfSensor(obj)
            indexOfSensor = obj.indexOfSensor;
        end

        function obj = set.Time(obj, time)
            obj.time = time;
        end
        function time = get.Time(obj)
            time = obj.time;
        end
    end

    methods (Access = private)
    end
end





