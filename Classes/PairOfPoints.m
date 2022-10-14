classdef PairOfPoints < handle
    properties (Access = private)
        leftPoint Point
        rightPoint Point
        typeOfPairs = PairOfPointsType.NotInstalled
    end

    properties (Dependent)
        LeftPoint
        RightPoint
        TypeOfPairs
        LeftTime
        RightTime
        LeftSensor
        RightSensor
    end

    methods
        function obj = PairOfPoints(leftPoint, rightPoint)
            obj.leftPoint = leftPoint;
            obj.rightPoint = rightPoint;
            SetPairOfPointsType(obj);
        end

        function set.LeftPoint(obj, leftPoint)
            obj.leftPoint = leftPoint;
        end
        function leftPoint = get.LeftPoint(obj)
            leftPoint = obj.leftPoint;
        end

        function set.RightPoint(obj, rightPoint)
            obj.rightPoint = rightPoint;
        end
        function rightPoint = get.RightPoint(obj)
            rightPoint = obj.rightPoint;
        end

        function typeOfPairs = get.TypeOfPairs(obj)
            typeOfPairs = obj.typeOfPairs;
        end

        function leftSensor = get.LeftSensor(obj)
            leftSensor = obj.leftPoint.IndexOfSensor;
        end
        function rightSensor = get.RightSensor(obj)
            rightSensor = obj.rightPoint.IndexOfSensor;
        end

        function leftTime = get.LeftTime(obj)
            leftTime = obj.leftPoint.Time;
        end
        function rightTime = get.RightTime(obj)
            rightTime = obj.rightPoint.Time;
        end

        function result = IsEqual(obj, pair)
            result = false;
            if obj.leftPoint.IsEqual(pair.leftPoint) == true &&...
               obj.rightPoint.IsEqual(pair.rightPoint) == true
                result = true;
            end
        end
    end

    methods (Access = public)
        function result = IsFormZ(obj, pairsOfPoints, checkDeltTime)
            result = false;
            [sameBeginningPairs, sameEndingPairs] = GetPairsWithSameEdges(obj, pairsOfPoints);
            if length(sameBeginningPairs) > 1 && length(sameEndingPairs) > 1
                if IsFormZCenterForAnyPairs(obj, sameBeginningPairs, sameEndingPairs, checkDeltTime)
                    result = true;
                end
            end
        end
        function result = HasSameBeginning(obj, pair2)
            if obj.LeftPoint.IsEqual(pair2.LeftPoint) == true
                result = true;
            else
                result = false;
            end
        end
        function result = HasSameEnding(obj, pair2)
            if obj.RightPoint.IsEqual(pair2.RightPoint) == true
                result = true;
            else
                result = false;
            end
        end

        function result = IsBeginningForPair(obj, pair2)
            if obj.RightPoint.IsEqual(pair2.LeftPoint) == true
                result = true;
            else
                result = false;
            end
        end
        function result = IsEndingForPair(obj, pair2)
            if obj.LeftPoint.IsEqual(pair2.RightPoint) == true
                result = true;
            else
                result = false;
            end
        end

        
        function deltTime = GetDeltTime(obj)
            deltTime = abs(obj.leftPoint.Time - obj.rightPoint.Time);
        end

        function result = HaveRightNeighbor(obj, setOfPairs)
            result = false;
            indexOfRightSensor = obj.RightSensor;
            rightPairs = setOfPairs{indexOfRightSensor};
            if ~isempty(rightPairs)
                for i = 1:1:length(rightPairs)
                    rightPair = rightPairs{i};
                    if obj.RightPoint.IsEqual(rightPair.LeftPoint)
                        result = true;
                        return;
                    end
                end
            end
        end
        function result = HaveLeftNeighbor(obj, setOfPairs)
            result = false;
            indexOfLeftSensor = obj.LeftSensor-1;
            if indexOfLeftSensor > 1
                leftPairs = setOfPairs{indexOfLeftSensor};
                if ~isempty(leftPairs)
                    for i = 1:1:length(leftPairs)
                        leftPair = leftPairs{i};
                        if obj.LeftPoint.IsEqual(leftPair.RightPoint)
                            result = true;
                            return;
                        end
                    end
                end
            end
        end
        
        function result = IsCrossingPairs(obj, otherPairs)
            result = false;
            for i = 1:1:length(otherPairs)
                otherPair = otherPairs{i};
                if IsCrossingPair(obj, otherPair) == true
                    result = true;
                    return;
                end
            end
        end
        function result = IsCrossingPair(obj, otherPair)
            result = false;
            if (obj.LeftSensor == otherPair.LeftSensor) && ...
               ((obj.LeftTime > otherPair.LeftTime && obj.RightTime < otherPair.RightTime) || ...
                (obj.LeftTime < otherPair.LeftTime && obj.RightTime > otherPair.RightTime))
                result = true;
                return;
            end
        end
    end

    methods (Access = private)
        function SetPairOfPointsType(obj)
            if obj.leftPoint.TypeOfPoint == PointType.Good && obj.rightPoint.TypeOfPoint == PointType.Good
                obj.typeOfPairs = PairOfPointsType.Good;
            elseif obj.leftPoint.TypeOfPoint == PointType.Good || ...
                    obj.rightPoint.TypeOfPoint == PointType.Good || ...
                    obj.leftPoint.TypeOfPoint == PointType.Additional || ...
                    obj.rightPoint.TypeOfPoint == PointType.Additional
                obj.typeOfPairs = PairOfPointsType.Additional;
            end
        end
    
        function [sameBeginningPairs, sameEndingPairs] = GetPairsWithSameEdges(obj, pairsOfPoints)
            sameBeginningPairs = [];
            sameEndingPairs = [];
            for i = 1:1:length(pairsOfPoints)
                pair2 = pairsOfPoints{i};
                if HasSameBeginning(obj, pair2) == true
                    sameBeginningPairs{end+1,1} = pair2;
                end
                if HasSameEnding(obj, pair2) == true
                    sameEndingPairs{end+1,1} = pair2;
                end
            end
        end
        

        function result = IsFormZCenterForAnyPairs(obj, sameBeginningPairs, sameEndingPairs, checkDeltTime)
            result = false;
            for i = 1:1:length(sameBeginningPairs)
                beginningPair = sameBeginningPairs{i};
                for j = 1:1:length(sameEndingPairs)
                    endingPair = sameEndingPairs{j};
                    if IsFormZCenterForCurrentTwoPairs(obj, beginningPair, endingPair, checkDeltTime) == true
                        result = true;
                    end
                end
            end
        end
        function result = IsFormZCenterForCurrentTwoPairs(obj, sameBeginningPair, sameEndingPair, checkDeltTime)
            result = false;
            if IsTypeOfZ1FormForTimes(obj, sameBeginningPair, sameEndingPair) == true || ...
               IsTypeOfZ2FormForTimes(obj, sameBeginningPair, sameEndingPair) == true
                if checkDeltTime == true 
                    if IsCentralDeltTimeMoreThanEdgeDeltTimes(obj, sameBeginningPair, sameEndingPair) == true
                        result = true;
                    end
                else
                    result = true;
                end
            end
        end
        function result = IsTypeOfZ1FormForTimes(obj, sameBeginningPair, sameEndingPair)
            result = false;
            leftTimeOfCurrentPair = obj.LeftPoint.Time;
            rightTimeOfCurrentPair = obj.RightPoint.Time;
            rightTimeOfSameBeginningPair = sameBeginningPair.RightTime;
            leftTimeOfSameEndingPair = sameEndingPair.LeftTime;
            if (leftTimeOfCurrentPair < leftTimeOfSameEndingPair && rightTimeOfCurrentPair > rightTimeOfSameBeginningPair)
                result = true;
            end
        end
        function result = IsTypeOfZ2FormForTimes(obj, sameBeginningPair, sameEndingPair)
            result = false;
            leftTimeOfCurrentPair = obj.LeftPoint.Time;
            rightTimeOfCurrentPair = obj.RightPoint.Time;
            rightTimeOfSameBeginningPair = sameBeginningPair.RightTime;
            leftTimeOfSameEndingPair = sameEndingPair.LeftTime;
            if (leftTimeOfCurrentPair > leftTimeOfSameEndingPair && rightTimeOfCurrentPair < rightTimeOfSameBeginningPair)
                result = true;
            end
        end
        function result = IsCentralDeltTimeMoreThanEdgeDeltTimes(obj, sameBeginningPair, sameEndingPair)
            result = false;
            deltTimeForPair = obj.GetDeltTime();
            deltTimeForSameBegPair = sameBeginningPair.GetDeltTime();
            deltTimeForSameEndPair = sameEndingPair.GetDeltTime();
            if deltTimeForPair > deltTimeForSameBegPair && deltTimeForPair > deltTimeForSameEndPair
                result = true;
            end
        end

        
    end
end




