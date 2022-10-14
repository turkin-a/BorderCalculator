classdef CheckedPairOfPoints < handle
    properties (Access = private)
        pairOfPoints PairOfPoints
        checked
        
    end

    properties (Dependent)
        Checked
        Pair

        LeftPoint
        RightPoint
        TypeOfPairs
        LeftTime
        RightTime
        LeftSensor
        RightSensor
    end

    methods
        function obj = CheckedPairOfPoints(pairOfPoints)
            obj.pairOfPoints = pairOfPoints;
            obj.checked = 0;
        end
        function checked = get.Checked(obj)
            checked = obj.checked;
        end
        function set.Checked(obj, checked)
            obj.checked = checked;
        end

        function pairOfPoints = get.Pair(obj)
            pairOfPoints = obj.pairOfPoints;
        end


        function leftPoint = get.LeftPoint(obj)
            leftPoint = obj.pairOfPoints.LeftPoint;
        end

        function rightPoint = get.RightPoint(obj)
            rightPoint = obj.pairOfPoints.RightPoint;
        end

        function typeOfPairs = get.TypeOfPairs(obj)
            typeOfPairs = obj.pairOfPoints.TypeOfPairs;
        end

        function leftSensor = get.LeftSensor(obj)
            leftSensor = obj.pairOfPoints.LeftSensor;
        end
        function rightSensor = get.RightSensor(obj)
            rightSensor = obj.pairOfPoints.RightSensor;
        end

        function leftTime = get.LeftTime(obj)
            leftTime = obj.pairOfPoints.LeftTime;
        end
        function rightTime = get.RightTime(obj)
            rightTime = obj.pairOfPoints.RightTime;
        end

        function result = IsEqual(obj, checkedPair)
            result = false;
            if obj.pairOfPoints.IsEqual(checkedPair.Pair) == true
                result = true;
            end
        end

        function result = HaveForkInRightPoint(obj, setOfPairs)
            result = false;            
            leftPairs  = obj.RightPoint.GetPairsWithRightTime(setOfPairs);            
            rightPairs = obj.RightPoint.GetPairsWithLeftTime (setOfPairs);
            if (length(leftPairs) > 1 && ~isempty(rightPairs)) || ...
               (~isempty(leftPairs) && length(rightPairs) > 1)
                result = true;
            end
        end
    end

    methods (Access = private)
        
    end
end