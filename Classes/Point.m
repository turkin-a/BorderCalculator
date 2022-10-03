classdef Point
    properties (Access = private)
        indexOfSensor (1,1) double = 0
        time (1,1) double = 0
        direction (1,1) double
        typeOfInterval IntervalType
    end

    properties (Dependent)
        IndexOfSensor
        Time
        Direction
        TypeOfInterval
    end

    methods
        function obj = Point(indexOfSensor, time, direction, typeOfInterval)
            obj.indexOfSensor = indexOfSensor;
            obj.time = time;
            obj.direction = direction;
            obj.typeOfInterval = typeOfInterval;
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

        function direction = get.Direction(obj)
            direction = obj.direction;
        end

        function typeOfInterval = get.TypeOfInterval(obj)
            typeOfInterval = obj.typeOfInterval;
        end
    end

    methods (Access = private)
    end
end





