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

    methods (Access = public)
        function result = IsEqual(obj, point2)
            result = false;
            if obj.IndexOfSensor == point2.IndexOfSensor && obj.Time == point2.Time
                result = true;
            end
        end

        function leftPairs = GetConnectedLeftPairs(obj, setOfPairs)
            leftPairs = [];
            begIndexOfSensor = obj.indexOfSensor - 1;
            if begIndexOfSensor > 0
                pairs = setOfPairs{begIndexOfSensor};
                if ~isempty(pairs)
                    for i = 1:1:length(pairs)
                        pair = pairs{i};
                        if pair.RightTime == obj.Time
                            leftPairs{end+1,1} = pair;
                        end
                    end
                end
            end
        end
        function rightPairs = GetConnectedRightPairs(obj, setOfPairs)
            rightPairs = [];
            begIndexOfSensor = obj.indexOfSensor;
            if begIndexOfSensor <= length(setOfPairs)
                pairs = setOfPairs{begIndexOfSensor};
                if ~isempty(pairs)
                    for i = 1:1:length(pairs)
                        pair = pairs{i};
                        if pair.LeftTime == obj.Time
                            rightPairs{end+1,1} = pair;
                        end
                    end
                end
            end
        end

        function pairs = GetPairsWithLeftTime(obj, setOfPairs)
            pairs = [];
            pairsForSensor = setOfPairs{obj.indexOfSensor};
            for i = 1:1:length(pairsForSensor)
                pair = pairsForSensor{i};
                if pair.LeftTime == obj.time
                    pairs{end+1,1} = pair;
                end
            end
        end
        function pairs = GetPairsWithRightTime(obj, setOfPairs)
            pairs = [];
            begIndexOfSensor = obj.indexOfSensor - 1;
            if begIndexOfSensor > 0
                pairsForSensor = setOfPairs{begIndexOfSensor};
                for i = 1:1:length(pairsForSensor)
                    pair = pairsForSensor{i};
                    if pair.RightTime == obj.time
                        pairs{end+1,1} = pair;
                    end
                end
            end
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





