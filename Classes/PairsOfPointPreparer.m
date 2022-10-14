classdef PairsOfPointPreparer < handle
    properties (Access = private)
        indexOfBegSensor
        indexOfEndSensor
        indexOfCentralSensor
        numberOfSensors

        Li
        dt
        firstTimes

        setOfPairsOfPoints1
        setOfPairsOfPoints2
    end
    properties (Access = private, Constant)
    end

    properties (Dependent)
        SetOfPairsOfPoints1
        SetOfPairsOfPoints2
    end

    methods
        function obj = PairsOfPointPreparer(seismogram)
            obj.indexOfBegSensor = ModelParameters.GetIndexOfBegSensor(seismogram);
            obj.indexOfEndSensor = ModelParameters.GetIndexOfEndSensor(seismogram);
            obj.indexOfCentralSensor = seismogram.IndexOfCentralSensor;
            obj.numberOfSensors = seismogram.NumberOfSensors;

            obj.Li = seismogram.GetDistancesFromSource();
            obj.dt = 1 / seismogram.NumberSamplesPerSec;
            obj.firstTimes = seismogram.FirstTimes;   
        end

        function setOfPairsOfPoints1 = get.SetOfPairsOfPoints1(obj)
            setOfPairsOfPoints1 = obj.setOfPairsOfPoints1;
        end

        function setOfPairsOfPoints2 = get.SetOfPairsOfPoints2(obj)
            setOfPairsOfPoints2 = obj.setOfPairsOfPoints2;
        end

        function Calculate(obj, setOfPairsOfPoints1, setOfPairsOfPoints2)
            setOfPairs1 = CorrectSetOfPairs(obj, setOfPairsOfPoints1);
            setOfPairs2 = CorrectSetOfPairs(obj, setOfPairsOfPoints2);
            obj.setOfPairsOfPoints1 = RemoveCrossingPairsFromSetOfPairs(obj, setOfPairs1, setOfPairs2);
            obj.setOfPairsOfPoints2 = RemoveCrossingPairsFromSetOfPairs(obj, setOfPairs2, setOfPairs1);
        end
    end

    methods(Access = private)
        function setOfPairs = CorrectSetOfPairs(obj, setOfPairs)
            setOfPairs = GetSetOfGoodPairs(obj, setOfPairs);
%             DataVisualizer.PlotSetOfPairsOfPoints(setOfPairs, 'r', 3);
            setOfPairs = RemoveFormZIntersactionFromSetOfPairs(obj, setOfPairs, true);
            setOfPairs = RemoveFormZIntersactionFromSetOfPairs(obj, setOfPairs, false);
            setOfPairs = RemoveAdjoinedSinglePair(obj, setOfPairs);
            setOfPairs = RemoveRhombuses(obj, setOfPairs);
            setOfPairs = RemoveForksFromSetOfPairs(obj, setOfPairs);
            
%             DataVisualizer.PlotSetOfPairsOfPoints(setOfPairs, 'b', 2);
        end
        function resultSetOfPairs = GetSetOfGoodPairs(obj, setOfPairs)
            resultSetOfPairs = cell(size(setOfPairs));
            for indexOfSensor = 1:1:obj.numberOfSensors
                pairs = setOfPairs{indexOfSensor};
                if ~isempty(pairs)
                    resultSetOfPairs{indexOfSensor} = GetGoodPairs(obj, pairs);
                end
            end
        end
        function resultPairs = GetGoodPairs(obj, pairs)
            resultPairs = [];
            for i = 1:1:length(pairs)
                pair = pairs{i};
                if pair.TypeOfPairs == PairOfPointsType.Good
                    resultPairs{end+1,1} = pair;
                end
            end
        end

        %%% RemoveFormZIntersactionFromSetOfPairs
        function setOfPairs = RemoveFormZIntersactionFromSetOfPairs(obj, setOfPairs, checkDeltTime)
            for indexOfSensor = 1:1:obj.numberOfSensors
                pointPairs = setOfPairs{indexOfSensor};
                if ~isempty(pointPairs)
                    pointPairs = RemoveFormZIntersactionFromPairs(obj, pointPairs, checkDeltTime);
                    setOfPairs{indexOfSensor} = pointPairs;
                end
            end
        end
        function pairsOfPointsResult = RemoveFormZIntersactionFromPairs(obj, pairsOfPoints, checkDeltTime)
            countOfPairs = length(pairsOfPoints);
            pairsOfPointsResult = [];
            for i = 1:1:countOfPairs
                pair1 = pairsOfPoints{i};
                if pair1.IsFormZ(pairsOfPoints, checkDeltTime) == false
                    pairsOfPointsResult{end+1,1} = pair1;
                end
            end
        end

        %%% RemoveAdjoinedSinglePair
        function resultSetOfPairs = RemoveAdjoinedSinglePair(obj, setOfPairs)
            resultSetOfPairs = cell(obj.numberOfSensors,1);
            for indexOfSensor = 1:1:obj.numberOfSensors
                pairs = setOfPairs{indexOfSensor};
                resultPairs = [];
                for i = 1:1:length(pairs)
                    pair = pairs{i};
                    if IsPairAdjoinedSingle(obj, pair, setOfPairs) == false
                        resultPairs{end+1,1} = pair;
                    end
                end
                resultSetOfPairs{indexOfSensor} = resultPairs;
            end
        end
        function result = IsPairAdjoinedSingle(obj, pair, setOfPairs)
            result = false;

            if IsPairAdjoinedSingleForLeftPoint(obj, pair, setOfPairs)  == true || ...
               IsPairAdjoinedSingleForRightPoint(obj, pair, setOfPairs) == true
                result = true;
            end
        end
        function result = IsPairAdjoinedSingleForLeftPoint(obj, pair, setOfPairs)
            result = false;
            [leftConnectedPairs, rightConnectedPairs] = GetInputAndOutputPairsForLeftSensor(obj, pair, setOfPairs);
            if ~isempty(leftConnectedPairs) && ~isempty(rightConnectedPairs)
                initPair{1} = pair;
                if DoesAnyPairHaveRightNeighbor(obj, rightConnectedPairs, setOfPairs) == true && ...
                   DoesAnyPairHaveRightNeighbor(obj, initPair, setOfPairs) == false   
                    result = true;
                end
            end
        end
        function [leftConnectedPairs, rightConnectedPairs] = GetInputAndOutputPairsForLeftSensor(obj, pair, setOfPairs)
            leftConnectedPairs = [];
            rightConnectedPairs = [];
            indexOfPairLeftSensor = pair.LeftSensor;
            indexOfLeftConnectedSensor = indexOfPairLeftSensor - 1;
            if indexOfLeftConnectedSensor > 1
                indexOfRightConnectedSensor = indexOfPairLeftSensor;
                leftPairsOfLeftSensor  = setOfPairs{indexOfLeftConnectedSensor};
                rightPairsOfLeftSensor = setOfPairs{indexOfRightConnectedSensor};
                if ~isempty(leftPairsOfLeftSensor) && ~isempty(rightPairsOfLeftSensor)
                    leftConnectedPairs = GetLeftPairsConnectedToLeftPointOfPair(obj, pair, leftPairsOfLeftSensor);
                    rightConnectedPairs = GetRightPairsConnectedToLeftPointOfPair(obj, pair, rightPairsOfLeftSensor);
                end
            end
        end
        function connectedPair = GetLeftPairsConnectedToLeftPointOfPair(obj, pair, leftPairsOfLeftPairPoint)
            connectedPair = [];
            for i = 1:1:length(leftPairsOfLeftPairPoint)
                leftPairOfLeftPairPoint = leftPairsOfLeftPairPoint{i};
                if pair.IsEqual(leftPairOfLeftPairPoint) == false && ...
                   pair.LeftPoint.IsEqual(leftPairOfLeftPairPoint.RightPoint)
                    connectedPair{end+1,1} = leftPairOfLeftPairPoint;
                end
            end
        end
        function connectedPair = GetRightPairsConnectedToLeftPointOfPair(obj, pair, rightPairsOfLeftPairPoint)
            connectedPair = [];
            for i = 1:1:length(rightPairsOfLeftPairPoint)
                rightPairOfLeftPairPoint = rightPairsOfLeftPairPoint{i};
                if pair.IsEqual(rightPairOfLeftPairPoint) == false && ...
                   pair.LeftPoint.IsEqual(rightPairOfLeftPairPoint.LeftPoint)
                    connectedPair{end+1,1} = rightPairOfLeftPairPoint;
                end
            end
        end
        function result = DoesAnyPairHaveRightNeighbor(obj, pairs, setOfPairs)
            result = false;
            for i = 1:1:length(pairs)
                pair = pairs{i};
                if pair.HaveRightNeighbor(setOfPairs)
                    result = true;
                    return;
                end
            end
        end

        function result = IsPairAdjoinedSingleForRightPoint(obj, pair, setOfPairs)
            result = false;
            [leftConnectedPairs, rightConnectedPairs] = GetInputAndOutputPairsForLeftSensor(obj, pair, setOfPairs);
            if ~isempty(leftConnectedPairs) && ~isempty(rightConnectedPairs)
                initPair{1} = pair;
                if DoesAnyPairHaveLeftNeighbor(obj, leftConnectedPairs, setOfPairs) == true && ...
                   DoesAnyPairHaveLeftNeighbor(obj, initPair, setOfPairs) == false   
                    result = true;
                end
            end
        end
        function [leftConnectedPairs, rightConnectedPairs] = GetInputAndOutputPairsForRightSensor(obj, pair, setOfPairs)
            leftConnectedPairs = [];
            rightConnectedPairs = [];
            indexOfPairLeftSensor = pair.RightSensor;
            indexOfLeftConnectedSensor = indexOfPairLeftSensor - 1;
            if indexOfLeftConnectedSensor > 1
                indexOfRightConnectedSensor = indexOfPairLeftSensor;
                leftPairsOfLeftSensor  = setOfPairs{indexOfLeftConnectedSensor};
                rightPairsOfLeftSensor = setOfPairs{indexOfRightConnectedSensor};
                if ~isempty(leftPairsOfLeftSensor) && ~isempty(rightPairsOfLeftSensor)
                    leftConnectedPairs = GetLeftPairsConnectedToRightPointOfPair(obj, pair, leftPairsOfLeftSensor);
                    rightConnectedPairs = GetRightPairsConnectedToRightPointOfPair(obj, pair, rightPairsOfLeftSensor);
                end
            end
        end
        function connectedPair = GetLeftPairsConnectedToRightPointOfPair(obj, pair, leftPairsOfRightPairPoint)
            connectedPair = [];
            for i = 1:1:length(leftPairsOfRightPairPoint)
                leftPairOfLeftPairPoint = leftPairsOfRightPairPoint{i};
                if pair.IsEqual(leftPairOfLeftPairPoint) == false && ...
                   pair.RightPoint.IsEqual(leftPairOfLeftPairPoint.RightPoint)
                    connectedPair{end+1,1} = leftPairOfLeftPairPoint;
                end
            end
        end
        function connectedPair = GetRightPairsConnectedToRightPointOfPair(obj, pair, rightPairsOfLeftPairPoint)
            connectedPair = [];
            for i = 1:1:length(rightPairsOfLeftPairPoint)
                rightPairOfLeftPairPoint = rightPairsOfLeftPairPoint{i};
                if pair.IsEqual(rightPairOfLeftPairPoint) == false && ...
                   pair.RightPoint.IsEqual(rightPairOfLeftPairPoint.LeftPoint)
                    connectedPair{end+1,1} = rightPairOfLeftPairPoint;
                end
            end
        end
        function result = DoesAnyPairHaveLeftNeighbor(obj, pairs, setOfPairs)
            result = false;
            for i = 1:1:length(pairs)
                pair = pairs{i};
                if pair.HaveLeftNeighbor(setOfPairs)
                    result = true;
                    return;
                end
            end
        end

        %%% RemoveRhombuses
        function setOfPairs = RemoveRhombuses(obj, setOfPairs)
            while true
                rhombus = GetRhombus(obj, setOfPairs);
                if isempty(rhombus)
                    break;
                end
                setOfPairs = RemoveRhombusFromSetOfPair(obj, setOfPairs, rhombus);
                [leftPair, rightPair] = rhombus.GetTwoPairsInsteadOfRombus();
                setOfPairs = AddPairInSetOfPairs(obj, setOfPairs, leftPair);
                setOfPairs = AddPairInSetOfPairs(obj, setOfPairs, rightPair);
            end            
        end
        function resultRhombus = GetRhombus(obj, setOfPairs)
            resultRhombus = [];
            for indexOfBeginningSensor = 1:1:obj.numberOfSensors
                rhombus = GetRhombusWithBeginInSensor(obj, setOfPairs, indexOfBeginningSensor);
                if ~isempty(rhombus)
                    resultRhombus = rhombus;
                    return;
                end
            end
        end
        function resultRhombus = GetRhombusWithBeginInSensor(obj, setOfPairs, indexOfLeftSensor)
            resultRhombus = [];
            indexOfCenterSensor = indexOfLeftSensor + 1;
            if IsIndexOfCentralSensorGood(obj, indexOfCenterSensor, setOfPairs) == false
                return;
            end
            allLeftPairs = setOfPairs{indexOfLeftSensor};
            allRightPairs = setOfPairs{indexOfCenterSensor};
            if ~isempty(allLeftPairs) && ~isempty(allRightPairs)
                [leftIndices] = GetIndicesOfLeftPartOfRhombus(obj, allLeftPairs);
                for i = 1:1:size(leftIndices,1)
                    leftIndex = leftIndices{i};
                    [leftUpPair, leftDownPair] = GetTwoPairsByIndex(obj, allLeftPairs, leftIndex);
                    [rightIndices] = GetIndicesOfRightPartOfRhombus(obj, leftUpPair, leftDownPair, allRightPairs);
                    for j = 1:1:length(rightIndices)
                        rightIndex = rightIndices{i};
                        [rightUpPair, rightDownPair] = GetTwoPairsByIndex(obj, allRightPairs, rightIndex);
                        rhombus = Rombus();
                        rhombus.SetPointsFormPairs(leftUpPair, leftDownPair, rightUpPair, rightDownPair);
                        if rhombus.GetMaxNumberOfPairAdjoinToTop(setOfPairs) <= 1 && ...
                           rhombus.GetMaxNumberOfPairAdjoinToBottom(setOfPairs) <= 1
                            resultRhombus = rhombus;
                            return;
                        end
                    end
                end
            end
        end
        function result = IsIndexOfCentralSensorGood(obj, indexOfCenterSensor, setOfPairs)
            result = true;
            if indexOfCenterSensor > obj.numberOfSensors || indexOfCenterSensor > length(setOfPairs)
                result = false;
            end
        end
        function [pair1, pair2] = GetTwoPairsByIndex(obj, pairs, index)
            indexOfPair1 = index(1);
            indexOfPair2 = index(2);
            pair1 = pairs{indexOfPair1};
            pair2 = pairs{indexOfPair2};
        end
        function [indices] = GetIndicesOfLeftPartOfRhombus(obj, allLeftPairs)
            indices = [];
            for index1 = 1:1:length(allLeftPairs)
                leftPair1 = allLeftPairs{index1};
                for index2 = 1:1:length(allLeftPairs)
                    leftPair2 = allLeftPairs{index2};
                    if leftPair1.HasSameBeginning(leftPair2) == true && ...
                       leftPair1.RightTime < leftPair2.RightTime
                        indices{end+1,1} = [index1 index2];
                    end
                end
            end
        end
        function [indices] = GetIndicesOfRightPartOfRhombus(obj, leftPair1, leftPair2, rightPairs)
            indices = [];
            for rightIndex1 = 1:1:length(rightPairs)
                rightPair1 = rightPairs{rightIndex1};
                if leftPair1.IsBeginningForPair(rightPair1) == true
                    for rightIndex2 = 1:1:length(rightPairs)
                        rightPair2 = rightPairs{rightIndex2};
                        if rightIndex1 ~= rightIndex2 && ...
                           leftPair2.IsBeginningForPair(rightPair2) && ...
                           rightPair1.HasSameEnding(rightPair2)
                            indices{end+1,1} = [rightIndex1 rightIndex2];
                        end
                    end
                end
            end
        end
        function setOfPairs = RemoveRhombusFromSetOfPair(obj, setOfPairs, rhombus)
            leftUpPair = rhombus.LeftUpPair;
            leftDownPair = rhombus.LeftDownPair;
            rightUpPair = rhombus.RightUpPair;
            rightDownPair = rhombus.RightDownPair;
            setOfPairs = RemovePairFromSetOfPair(obj, setOfPairs, leftUpPair);
            setOfPairs = RemovePairFromSetOfPair(obj, setOfPairs, leftDownPair);
            setOfPairs = RemovePairFromSetOfPair(obj, setOfPairs, rightUpPair);
            setOfPairs = RemovePairFromSetOfPair(obj, setOfPairs, rightDownPair);
        end
        function setOfPairs = RemovePairFromSetOfPair(obj, setOfPairs, pairToRemove)
            indexOfSensor = pairToRemove.LeftSensor;
            pairs = setOfPairs{indexOfSensor};
            for i = 1:1:length(pairs)
                pair = pairs{i};
                if pair.IsEqual(pairToRemove) == true
                    pairs(i) = [];
                    setOfPairs{indexOfSensor} = pairs;
                    return;
                end
            end
        end
        function setOfPairs = AddPairInSetOfPairs(obj, setOfPairs, pair)
            pairs = setOfPairs{pair.LeftSensor};
            pairs{end+1,1} = pair;
            setOfPairs{pair.LeftSensor} = pairs;
        end

        function setOfPairs = RemoveForksFromSetOfPairs(obj, setOfPairs)
            while true
                fork = GetForkFromSetOfPairs(obj, setOfPairs);
                if isempty(fork)
                    break;
                end
                setOfPairs = RemoveForkFromSetOfPairs(obj, fork, setOfPairs);
            end
        end
        function fork = GetForkFromSetOfPairs(obj, setOfPairs)
            fork = [];
            for indexOfSensor = 1:1:obj.numberOfSensors
                pairs = setOfPairs{indexOfSensor};
                if ~isempty(pairs)
                    leftPoint = GetLeftPointOfCrossedPairs(obj, pairs);
                    if ~isempty(leftPoint)
                        leftPairs = leftPoint.GetConnectedLeftPairs(setOfPairs);
                        rightPairs = leftPoint.GetConnectedRightPairs(setOfPairs);
                        if ~isempty(leftPairs) && ~isempty(rightPairs)
                            fork = PairFork(leftPairs, rightPairs);
                            return;
                        end
                    end
                    rightPoint = GetRightPointOfCrossedPairs(obj, pairs);
                    if ~isempty(rightPoint)
                        leftPairs = rightPoint.GetConnectedLeftPairs(setOfPairs);
                        rightPairs = rightPoint.GetConnectedRightPairs(setOfPairs);
                        if ~isempty(leftPairs) && ~isempty(rightPairs)
                            fork = PairFork(leftPairs, rightPairs);
                            return;
                        end
                    end
                end
            end
        end
        function resultPoint = GetLeftPointOfCrossedPairs(obj, pairs)
            resultPoint = [];
            for i = 1:1:length(pairs)-1
                pair1 = pairs{i};
                for j = i+1:1:length(pairs)
                    pair2 = pairs{j};
                    if pair1.LeftPoint.IsEqual(pair2.LeftPoint) == true
                        resultPoint = pair1.LeftPoint;
                    end
                end
            end
        end
        function resultPoint = GetRightPointOfCrossedPairs(obj, pairs)
            resultPoint = [];
            for i = 1:1:length(pairs)-1
                pair1 = pairs{i};
                for j = i+1:1:length(pairs)
                    pair2 = pairs{j};
                    if pair1.RightPoint.IsEqual(pair2.RightPoint) == true
                        resultPoint = pair1.RightPoint;
                    end
                end
            end
        end
        function setOfPairs = RemoveForkFromSetOfPairs(obj, fork, setOfPairs)
            pairsToRemove = fork.GetPairsToRemove();
            for i = 1:1:length(pairsToRemove)
                pairToRemove = pairsToRemove{i};
                setOfPairs = RemovePairFromSetOfPair(obj, setOfPairs, pairToRemove);
            end
        end

        % RemoveCrossingPairs
        function correctedSetOfPairs = RemoveCrossingPairsFromSetOfPairs(obj, correctedSetOfPairs, otherSetOfPairs)
            for i = 1:1:length(correctedSetOfPairs)
                pairs = correctedSetOfPairs{i};
                if i <= length(otherSetOfPairs)
                    otherPairs = otherSetOfPairs{i};
                    if ~isempty(pairs) && ~isempty(otherPairs)
                        pairs = RemoveCrossingPairsFromPairs(obj, pairs, otherPairs);
                        correctedSetOfPairs{i} = pairs;
                    end
                end
            end
        end
        function resultPairs = RemoveCrossingPairsFromPairs(obj, correctedPairs, otherPairs)
            resultPairs = [];
            for i = 1:1:length(correctedPairs)
                pair = correctedPairs{i};
                if pair.IsCrossingPairs(otherPairs) == false
                    resultPairs{end+1,1} = pair;
                end
            end
        end
        



    end
end



