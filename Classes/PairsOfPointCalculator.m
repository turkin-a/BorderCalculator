classdef PairsOfPointCalculator < handle
    properties (Access = private)
        setOfPoints1
        setOfPoints2
        setOfParams1
        setOfParams2

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
        minGoodDeltTimeForPairOfPoint = 50
        maxGoodDeltTimeFromAxis = 5
    end

    properties (Dependent)
        SetOfPoints1
        SetOfPoints2
        SetOfPermissibleAxesParams1
        SetOfPermissibleAxesParams2

        SetOfPairsOfPoints1
        SetOfPairsOfPoints2
    end

    methods
        function obj = PairsOfPointCalculator(seismogram)
            obj.indexOfBegSensor = ModelParameters.GetIndexOfBegSensor(seismogram);
            obj.indexOfEndSensor = ModelParameters.GetIndexOfEndSensor(seismogram);
            obj.indexOfCentralSensor = seismogram.IndexOfCentralSensor;
            obj.numberOfSensors = seismogram.NumberOfSensors;

            obj.Li = seismogram.GetDistancesFromSource();
            obj.dt = 1 / seismogram.NumberSamplesPerSec;
            obj.firstTimes = seismogram.FirstTimes;            
        end

        function setOfPoints1 = get.SetOfPoints1(obj)
            setOfPoints1 = obj.setOfPoints1;
        end
        function set.SetOfPoints1(obj, setOfPoints1)
            obj.setOfPoints1 = setOfPoints1;
        end

        function setOfPoints2 = get.SetOfPoints2(obj)
            setOfPoints2 = obj.setOfPoints2;
        end
        function set.SetOfPoints2(obj, setOfPoints2)
            obj.setOfPoints2 = setOfPoints2;
        end

        function setOfParams1 = get.SetOfPermissibleAxesParams1(obj)
            setOfParams1 = obj.setOfParams1;
        end
        function set.SetOfPermissibleAxesParams1(obj, setOfParams1)
            obj.setOfParams1 = setOfParams1;
        end

        function setOfParams2 = get.SetOfPermissibleAxesParams2(obj)
            setOfParams2 = obj.setOfParams2;
        end
        function set.SetOfPermissibleAxesParams2(obj, setOfParams2)
            obj.setOfParams2 = setOfParams2;
        end

        function setOfPairsOfPoints1 = get.SetOfPairsOfPoints1(obj)
            setOfPairsOfPoints1 = obj.setOfPairsOfPoints1;
        end
        function setOfPairsOfPoints2 = get.SetOfPairsOfPoints2(obj)
            setOfPairsOfPoints2 = obj.setOfPairsOfPoints2;
        end

        function Calculate(obj)
            obj.setOfPairsOfPoints1 = GetAndCalculateSetOfPairsOfPointsForDirection(obj, obj.setOfPoints1, obj.setOfParams1);
            obj.setOfPairsOfPoints2 = GetAndCalculateSetOfPairsOfPointsForDirection(obj, obj.setOfPoints2, obj.setOfParams2);
        end
    end

    methods (Access = private)
        function setOfPairsOfPoints = GetAndCalculateSetOfPairsOfPointsForDirection(obj, setOfPoints, setOfParams)
            setOfPairsOfPoints = cell(obj.numberOfSensors,1);
            for indexOfSensor = obj.indexOfBegSensor:1:obj.indexOfEndSensor
                pairs = GetAndCalculatePairsOfPointsForDirection (obj, setOfPoints, setOfParams, indexOfSensor);
                setOfPairsOfPoints{indexOfSensor,1} = pairs;
            end
        end

        function pairs = GetAndCalculatePairsOfPointsForDirection (obj, setOfPoints, setOfParams, indexOfSensor1)
            pairs = [];
            indexOfSensor2 = indexOfSensor1 + 1;
            if indexOfSensor2 > obj.numberOfSensors
                return;
            end
            pointsForSensor1 = setOfPoints{indexOfSensor1};
            pointsForSensor2 = setOfPoints{indexOfSensor2};
            if isempty(pointsForSensor1) || isempty(pointsForSensor2)
                return;
            end
            for i = 1:1:length(pointsForSensor1)
                point1 = pointsForSensor1{i};
                for j = 1:1:length(pointsForSensor2)
                    point2 = pointsForSensor2{j};
                    if IsPairGood(obj, point1, point2, setOfParams)
                        pair = PairOfPoints(point1, point2);
                        pairs{end+1,1} = pair;
                    end
                end
            end
        end

        function result = IsPairGood(obj, point1, point2, setOfParams)
            result = false;
            if abs(point1.Time-point2.Time) > obj.minGoodDeltTimeForPairOfPoint
                return;
            end
            iSensors = [point1.IndexOfSensor point2.IndexOfSensor];
            curDistances = obj.Li(iSensors);
            timesOfPoints = [point1.Time point2.Time];
            for i = 1:1:length(setOfParams)
                axisParameters = setOfParams{i};
                timesOfAxis = Axis.GetTimesByAxisParams(axisParameters, curDistances, obj.dt);
                if max(abs(timesOfPoints - timesOfAxis)) <= obj.maxGoodDeltTimeFromAxis
                    result = true;
                end
            end
        end



    end
end




