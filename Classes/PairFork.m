classdef PairFork < handle
    properties (Access = private)
        leftPairs
        rightPairs
    end

    properties (Dependent)
        LeftPairs
        RightPairs
    end

    methods
        function obj = PairFork(leftPairs, rightPairs)
            obj.leftPairs = leftPairs;
            obj.rightPairs = rightPairs;
        end

        
        function leftPairs = get.LeftPairs(obj)
            leftPairs = obj.leftPairs;
        end
        function rightPairs = get.RightPairs(obj)
            rightPairs = obj.rightPairs;
        end

        function pairs = GetPairsToRemove(obj)
            pairs = [];
            if length(obj.leftPairs) == 1 && length(obj.rightPairs) >= 2
                pairs = GetRightPairsToRemove(obj);
            elseif length(obj.leftPairs) >= 2 && length(obj.rightPairs) == 1
                pairs = GetLeftPairsToRemove(obj);
            elseif length(obj.leftPairs) >= 2 && length(obj.rightPairs) == 2
                % Logger / TesterVisualizer
                % TODO
                pairs = GetAllPairs(obj);
            end
        end
    end

    methods (Access = private)
        function pairs = GetRightPairsToRemove(obj)
            index = GetIndexOfGoodPair(obj, obj.leftPairs{1}, obj.rightPairs);
            pairs = GetPairsExceptOnePair(obj, obj.rightPairs, index);
        end
        function pairs = GetLeftPairsToRemove(obj)
            index = GetIndexOfGoodPair(obj, obj.rightPairs{1}, obj.leftPairs);
            pairs = GetPairsExceptOnePair(obj, obj.leftPairs, index);
        end
        function index = GetIndexOfGoodPair(obj, goodPair, pairs)
            exampleDeltTime = goodPair.GetDeltTime();
            timeDifferaceOfLeftAndRightPairs = [];
            for i = 1:1:length(pairs)
                curPair = pairs{i};
                curDeltTime = curPair.GetDeltTime();
                timeDifferaceOfLeftAndRightPairs(i,1) = abs(curDeltTime - exampleDeltTime);
            end
            index = find(timeDifferaceOfLeftAndRightPairs == min(timeDifferaceOfLeftAndRightPairs),1);
        end
        function resultPairs = GetPairsExceptOnePair(obj, pairs, index)
            indices = 1:length(pairs);
            indices(index) = [];
            resultPairs = pairs(indices);
        end
        function resultPairs = GetAllPairs(obj)
            resultPairs = [obj.leftPairs; obj.rightPairs];
        end
    end
end