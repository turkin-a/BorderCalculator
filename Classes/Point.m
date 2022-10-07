classdef Point < handle
    properties (Access = private)
        indexOfSensor (1,1) double = 0
        time (1,1) double = 0
        direction (1,1) double
        typeOfInterval IntervalType
        typeOfPoint PointType = PointType.NotInstalled
    end

    properties (Dependent)
        IndexOfSensor
        Time
        Direction
        TypeOfInterval
        TypeOfPoint
    end

    methods
        function obj = Point(indexOfSensor, time, direction, typeOfInterval)
            obj.indexOfSensor = indexOfSensor;
            obj.time = time;
            obj.direction = direction;
            obj.typeOfInterval = typeOfInterval;
            obj.TypeOfPoint = Point.GetTypeOfPointByTypeOfInterval(typeOfInterval);
        end

        function set.IndexOfSensor(obj, indexOfSensor)
            obj.indexOfSensor = indexOfSensor;
        end
        function indexOfSensor = get.IndexOfSensor(obj)
            indexOfSensor = obj.indexOfSensor;
        end

        function set.Time(obj, time)
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

        function typeOfPoint = get.TypeOfPoint(obj)
            typeOfPoint = obj.typeOfPoint;
        end
        function set.TypeOfPoint(obj, typeOfPoint)
            obj.typeOfPoint = typeOfPoint;
        end
    end

    methods (Access = public, Static)
        function typeOfPoint = GetTypeOfPointByTypeOfInterval(typeOfInterval)
            switch typeOfInterval
                case IntervalType.Good
                    typeOfPoint = PointType.Good;
                case IntervalType.Additional
                    typeOfPoint = PointType.Additional;
                otherwise
                    typeOfPoint = PointType.NotInstalled;
            end
        end
    end

    methods (Access = private)
    end
end





