classdef WayCalculator < handle
    properties (Access = private)
        indexOfBegSensor
        indexOfEndSensor
        indexOfCentralSensor
        numberOfSensors

        Li
        dt
        firstTimes

        initialSetOfPairs1
        initialSetOfPairs2
        preparedSetOfPairs1
        preparedSetOfPairs2
        ways1
        ways2

        
    end
    properties (Access = private, Constant)
    end

    properties (Dependent)
        InitialSetOfPairs1
        InitialSetOfPairs2
        PreparedSetOfPairs1
        PreparedSetOfPairs2
        Ways1
        Ways2
    end

    methods
        function obj = WayCalculator(seismogram)
            obj.indexOfBegSensor = ModelParameters.GetIndexOfBegSensor(seismogram);
            obj.indexOfEndSensor = ModelParameters.GetIndexOfEndSensor(seismogram);
            obj.indexOfCentralSensor = seismogram.IndexOfCentralSensor;
            obj.numberOfSensors = seismogram.NumberOfSensors;

            obj.Li = seismogram.GetDistancesFromSource();
            obj.dt = 1 / seismogram.NumberSamplesPerSec;
            obj.firstTimes = seismogram.FirstTimes;   
        end

        function initialSetOfPairsOfPoints1 = get.InitialSetOfPairs1(obj)
            initialSetOfPairsOfPoints1 = obj.initialSetOfPairs1;
        end
        function set.InitialSetOfPairs1(obj, initialSetOfPairsOfPoints1)
            obj.initialSetOfPairs1 = initialSetOfPairsOfPoints1;
        end

        function initialSetOfPairsOfPoints2 = get.InitialSetOfPairs2(obj)
            initialSetOfPairsOfPoints2 = obj.initialSetOfPairs2;
        end
        function set.InitialSetOfPairs2(obj, initialSetOfPairsOfPoints2)
            obj.initialSetOfPairs2 = initialSetOfPairsOfPoints2;
        end

        function preparedSetOfPairsOfPoints1 = get.PreparedSetOfPairs1(obj)
            preparedSetOfPairsOfPoints1 = obj.preparedSetOfPairs1;
        end
        function set.PreparedSetOfPairs1(obj, preparedSetOfPairsOfPoints1)
            obj.preparedSetOfPairs1 = preparedSetOfPairsOfPoints1;
        end

        function preparedSetOfPairsOfPoints2 = get.PreparedSetOfPairs2(obj)
            preparedSetOfPairsOfPoints2 = obj.preparedSetOfPairs2;
        end
        function set.PreparedSetOfPairs2(obj, preparedSetOfPairsOfPoints2)
            obj.preparedSetOfPairs2 = preparedSetOfPairsOfPoints2;
        end

        function ways1 = get.Ways1(obj)
            ways1 = obj.ways1;
        end
        function ways2 = get.Ways2(obj)
            ways2 = obj.ways2;
        end


        function Calculate(obj)
            obj.ways1 = GetWaysWithoutForksForGoodPairs(obj, obj.preparedSetOfPairs1);
        end
    end

    methods(Access = private)
        function ways = GetWaysWithoutForksForGoodPairs(obj, setOfPairs)
            ways = [];
            setOfCheckedPairs = CreateSetOfCheckedPairs(obj, setOfPairs);
            for indexOfSensor = 1:1:length(setOfCheckedPairs)
                checkedPairs = setOfCheckedPairs{indexOfSensor};                
                if ~isempty(checkedPairs)
                    for indexOfPairs = 1:1:length(checkedPairs)
                        checkedPair = checkedPairs{indexOfPairs};
                        if checkedPair.Checked == false
                            [way, setOfCheckedPairs] = BuildWayWithoutForks(obj, setOfCheckedPairs, checkedPair);
                            ways{end+1,1} = way;
                        end
                    end
                end
            end
        end
        function setOfCheckedPairs = CreateSetOfCheckedPairs(obj, setOfPairs)
            setOfCheckedPairs = cell(size(setOfPairs));
            for indexOfSensor = 1:1:length(setOfCheckedPairs)
                pairs = setOfPairs{indexOfSensor};
                checkedPairs = cell(size(pairs));
                for i = 1:1:length(pairs)
                    pair = pairs{i};
                    checkedPairs{i} = CheckedPairOfPoints(pair);
                end
                setOfCheckedPairs{indexOfSensor} = checkedPairs;
            end
        end
        function [resultWay, checkedSetOfPairs] = BuildWayWithoutForks(obj, checkedSetOfPairs, curPair)
            resultWay{1,1} = curPair;
            curPair.Checked = true;
            doesPairHaveForkInRightPoint = curPair.HaveForkInRightPoint(checkedSetOfPairs);
            indexOfSensor = curPair.RightSensor;
            prevPair = curPair;
            while ~doesPairHaveForkInRightPoint && indexOfSensor < length(checkedSetOfPairs)
                pairs = prevPair.RightPoint.GetPairsWithLeftTime(obj, checkedSetOfPairs);
                if length(pairs) ~= 1
                    break;
                end
                
                curPair = pairs{1};
                if curPair.Checked == true
                    return;
                end
                
                checkedPairs(index) = true;
                checkedSetOfPairs{indexOfSensor} = checkedPairs;
                resultWay{end+1,1} = checkedPairs;
                doesPairHaveForkInRightPoint = DoesPairHaveForkInRightPoint(obj, checkedPairs, setOfPairs);
                prevPair = curPair;
                indexOfSensor = indexOfSensor + 1;
            end
        end




    end
end



