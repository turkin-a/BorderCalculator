classdef Rombus < handle
    properties (Access = private)
        leftUpPair PairOfPoints
        leftDownPair PairOfPoints
        rightUpPair PairOfPoints
        rightDownPair PairOfPoints
    end

    properties (Dependent)
        LeftPoint
        RightPoint
        TopPoint
        BottomPoint

        LeftUpPair
        LeftDownPair
        RightUpPair
        RightDownPair
    end

    methods
        function leftPoint = get.LeftPoint(obj)
            leftPoint = [];
            if ~isempty(obj.leftUpPair)
                leftPoint = obj.leftUpPair.LeftPoint;
            end
        end
        function rightPoint = get.RightPoint(obj)
            rightPoint = [];
            if ~isempty(obj.rightUpPair)
                rightPoint = obj.rightUpPair.RightPoint;
            end
        end
        function topPoint = get.TopPoint(obj)
            topPoint = [];
            if ~isempty(obj.leftUpPair)
                topPoint = obj.leftUpPair.RightPoint;
            end
        end
        function bottomPoint = get.BottomPoint(obj)
            bottomPoint = [];
            if ~isempty(obj.leftDownPair)
                bottomPoint = obj.leftDownPair.RightPoint;
            end
        end

        function leftUpPair = get.LeftUpPair(obj)
            leftUpPair = obj.leftUpPair;
        end
        function leftDownPair = get.LeftDownPair(obj)
            leftDownPair = obj.leftDownPair;
        end
        function rightUpPair = get.RightUpPair(obj)
            rightUpPair = obj.rightUpPair;
        end
        function rightDownPair = get.RightDownPair(obj)
            rightDownPair = obj.rightDownPair;
        end


        function SetPointsFormPairs(obj, leftUpPair, leftDownPair, rightUpPair, rightDownPair)
            obj.leftUpPair = leftUpPair;
            obj.leftDownPair = leftDownPair;
            obj.rightUpPair = rightUpPair;
            obj.rightDownPair = rightDownPair;
        end

        function countPairToTop = GetMaxNumberOfPairAdjoinToTop(obj, setOfPairs)
            countOfIncomePair = GetCountOfIncomePairToPoint(obj, setOfPairs, obj.TopPoint);
            countOfOutcomePair = GetCountOfOutcomePairFromPoint(obj, setOfPairs, obj.TopPoint);
            countPairToTop = max([countOfIncomePair countOfOutcomePair]);
        end
        function countPairToBottom = GetMaxNumberOfPairAdjoinToBottom(obj, setOfPairs)
            countOfIncomePair = GetCountOfIncomePairToPoint(obj, setOfPairs, obj.BottomPoint);
            countOfOutcomePair = GetCountOfOutcomePairFromPoint(obj, setOfPairs, obj.BottomPoint);
            countPairToBottom = max([countOfIncomePair countOfOutcomePair]);
        end

        function [leftPair, rightPair] = GetTwoPairsInsteadOfRombus(obj)
            newTime = round(mean([obj.TopPoint.Time obj.BottomPoint.Time]));
            newCenterPoint = Point(obj.TopPoint.IndexOfSensor, newTime, obj.TopPoint.Direction, obj.TopPoint.TypeOfInterval);
            leftPair  = PairOfPoints(obj.LeftPoint, newCenterPoint);
            rightPair = PairOfPoints(newCenterPoint, obj.RightPoint);
        end
        
    end

    methods (Access = private)
        function countOfIncomePair = GetCountOfIncomePairToPoint(obj, setOfPairs, point)
            countOfIncomePair = 0;
            indexOfBeginningSensor = point.IndexOfSensor - 1;
            if indexOfBeginningSensor > 0
                pairs = setOfPairs{indexOfBeginningSensor};
                for i = 1:1:length(pairs)
                    pair = pairs{i};
                    if pair.RightTime == point.Time
                        countOfIncomePair = countOfIncomePair + 1;
                    end
                end
            end
        end
        function countOfOutcomePair = GetCountOfOutcomePairFromPoint(obj, setOfPairs, point)
            countOfOutcomePair = 0;
            indexOfBeginningSensor = point.IndexOfSensor;
            if indexOfBeginningSensor > 0
                pairs = setOfPairs{indexOfBeginningSensor};
                for i = 1:1:length(pairs)
                    pair = pairs{i};
                    if pair.LeftTime == point.Time
                        countOfOutcomePair = countOfOutcomePair + 1;
                    end
                end
            end
        end
        
    end
end