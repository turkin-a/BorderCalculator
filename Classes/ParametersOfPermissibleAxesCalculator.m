classdef ParametersOfPermissibleAxesCalculator < handle
    properties (Access = private)
        ransacCalculator
        setOfPoints1
        setOfPoints2

        indexOfBegSensor
        indexOfEndSensor
        indexOfCentralSensor

        Li
        directWaveVelocity
        dt
        firstTimes
        
        tableOfTimeSensor
        resultSetOfParams
        setOfParams1
        setOfParams2
    end
    properties (Access = private, Constant)
        maxTubeDetlTime = 2
        maxOffsetX = 150
        minSensorDistance = 2
        maxDeltTimePerSensor = 30
        minPointCount = 7

    end

    properties (Dependent)
        SetOfPoints1
        SetOfPoints2
        SetOfPermissibleAxesParams1
        SetOfPermissibleAxesParams2
    end

    methods
        function obj = ParametersOfPermissibleAxesCalculator(seismogram, directWaveVelocity)
            obj.ransacCalculator = RansacCalculator(seismogram, directWaveVelocity);
            obj.indexOfBegSensor = ModelParameters.GetIndexOfBegSensor(seismogram);
            obj.indexOfEndSensor = ModelParameters.GetIndexOfEndSensor(seismogram);
            obj.indexOfCentralSensor = seismogram.IndexOfCentralSensor;

            obj.Li = seismogram.GetDistancesFromSource();
            obj.directWaveVelocity = directWaveVelocity;
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
        function setOfParams2 = get.SetOfPermissibleAxesParams2(obj)
            setOfParams2 = obj.setOfParams2;
        end

        function Calculate(obj)
            obj.setOfParams1 = GetAndCalculateParamsForDirection(obj, obj.setOfPoints1);
            obj.setOfParams2 = GetAndCalculateParamsForDirection(obj, obj.setOfPoints2);
        end
    end

    methods (Access = private)
        function resultSetOfParams = GetAndCalculateParamsForDirection(obj, setOfPoints)
            obj.resultSetOfParams = [];
            CalculateAxesParametersByEnumeratingSensors(obj, setOfPoints);
            resultSetOfParams = obj.resultSetOfParams;
        end

        

        function CalculateAxesParametersByEnumeratingSensors(obj, setOfPoints)
            CalculateTableOfTimeAndSensorsForRansac(obj, setOfPoints);
            [mIndices1, mIndices2, mIndices3] = GetIndicesOfSensorsForCalculateOfAxesParameters(obj);
            for indexOfSensor1 = mIndices1
                for indexOfSensor2 = mIndices2
                    for indexOfSensor3 = mIndices3
                        indices = [indexOfSensor1, indexOfSensor2, indexOfSensor3];
                        if IsGroupOfSensorIndicesGood(obj, setOfPoints, indices) == true
                            CalculateAxesParametersByEnumeratingTimes(obj, setOfPoints, indices);
                        end
                    end
                end
            end

            g = 1;
            
        end
        function [mIndices1, mIndices2, mIndices3] = GetIndicesOfSensorsForCalculateOfAxesParameters(obj)
            mIndices1 = GetIndicesForFirstPartOfSensors(obj);
            mIndices2 = GetIndicesForSecondPartOfSensors(obj);
            mIndices3 = GetIndicesForThirdOfSensors(obj);
        end
        % Ближайшая группа датчиков к источнику (наименьшая дистанция/время)
        function mIndices1 = GetIndicesForFirstPartOfSensors(obj)
            leftIndex = GetIndexOfLastSensorOfSecondThird(obj) - 12;
            rightIndex = GetIndexOfLastSensorOfThirdThird(obj) - 1;
            maxDistance = abs(obj.indexOfCentralSensor - leftIndex);
            minDistance = abs(obj.indexOfCentralSensor - rightIndex);
            mIndices1 = [leftIndex:rightIndex obj.indexOfCentralSensor+minDistance:obj.indexOfCentralSensor+maxDistance];
        end
        % Центральная группа датчиков к источнику (средняя дистанция/время)
        function mIndices2 = GetIndicesForSecondPartOfSensors(obj)
            leftIndex  = GetIndexOfLastSensorOfFirstThird(obj) - 5;            
            rightIndex = GetIndexOfLastSensorOfSecondThird(obj) + 5;
            maxDistance = abs(obj.indexOfCentralSensor - leftIndex);
            minDistance = abs(obj.indexOfCentralSensor - rightIndex);
            mIndices2 = [leftIndex:rightIndex obj.indexOfCentralSensor+minDistance:obj.indexOfCentralSensor+maxDistance];
        end
        % Дальняя группа датчиков к источнику (наибольшая дистанция/время)
        function mIndices3 = GetIndicesForThirdOfSensors(obj)
            leftIndex  = obj.indexOfBegSensor;
            rightIndex = GetIndexOfLastSensorOfFirstThird(obj) + 3;
            maxDistance = abs(obj.indexOfCentralSensor - leftIndex);
            minDistance = abs(obj.indexOfCentralSensor - rightIndex);
            mIndices3 = [leftIndex:rightIndex obj.indexOfCentralSensor+minDistance:obj.indexOfCentralSensor+maxDistance];
        end

        function index = GetIndexOfLastSensorOfFirstThird(obj)
            index = round((obj.indexOfCentralSensor-obj.indexOfBegSensor) * 1 / 3 + obj.indexOfBegSensor);
        end
        function index = GetIndexOfLastSensorOfSecondThird(obj)
            index = round((obj.indexOfCentralSensor-obj.indexOfBegSensor) * 2 / 3 + obj.indexOfBegSensor);
        end
        function index = GetIndexOfLastSensorOfThirdThird(obj)
            index = obj.indexOfCentralSensor;
        end

        function CalculateTableOfTimeAndSensorsForRansac(obj, setOfPoints)
            obj.tableOfTimeSensor = obj.ransacCalculator.GetTableOfAllPointParameters(setOfPoints);
        end
        function result = IsGroupOfSensorIndicesGood(obj, setOfPoints, indices)
            result = false;
            indexOfSensor1 = indices(1);
            indexOfSensor2 = indices(2);
            indexOfSensor3 = indices(3);
            if IsIndexDistanceOfThreeSensorsGood(obj, indexOfSensor1, indexOfSensor2, indexOfSensor3) == true && ...
               IsGroupOfThreeSensorIndicesInOneSide(obj, indexOfSensor1, indexOfSensor2, indexOfSensor3) == true && ...
               IsPointsExistedByIndexOfSensor(obj, setOfPoints, indexOfSensor1) == true && ...
               IsPointsExistedByIndexOfSensor(obj, setOfPoints, indexOfSensor1) == true && ...
               IsPointsExistedByIndexOfSensor(obj, setOfPoints, indexOfSensor3) == true               
                % indexOfSensor1 < indexOfSensor2 < indexOfSensor2
                if IsDistanceOfTwoSensorGood(obj, indexOfSensor1, indexOfSensor2) && ...
                   IsDistanceOfTwoSensorGood(obj, indexOfSensor2, indexOfSensor3)
                    result = true;
                end
            end
        end
        function result = IsIndexDistanceOfThreeSensorsGood(obj, indexOfSensor1, indexOfSensor2, indexOfSensor3)
            result = false;
            if indexOfSensor1 ~= indexOfSensor2 && ...
               indexOfSensor1 ~= indexOfSensor3 && ...
               indexOfSensor2 ~= indexOfSensor3 && ...
               (indexOfSensor1 - indexOfSensor2) >= obj.minSensorDistance && ...
               (indexOfSensor1 - indexOfSensor3) >= obj.minSensorDistance && ...
               (indexOfSensor2 - indexOfSensor3) >= obj.minSensorDistance
                result = true;
            end
        end
        function result = IsGroupOfThreeSensorIndicesInOneSide(obj, indexOfSensor1, indexOfSensor2, indexOfSensor3)
            result = false;
            x1 = obj.Li(indexOfSensor1);
            x2 = obj.Li(indexOfSensor2);
            x3 = obj.Li(indexOfSensor3);
            if ((x1 > 0 && x2 > 0 && x3 > 0) || (x1 < 0 && x2 < 0 && x3 < 0))
                result = true;
            end
        end
        function result = IsPointsExistedByIndexOfSensor(obj, setOfPoints, indexOfSensor)
            result = false;
            if ~isempty(setOfPoints{indexOfSensor})
                result = true;
            end
        end
        function result = IsDistanceOfTwoSensorGood(obj, indexOfMinDistance, indexOfMaxDistance)
            result = false;
            minDistance = abs(obj.Li(indexOfMinDistance));
            maxDistance = abs(obj.Li(indexOfMaxDistance));
            if minDistance < maxDistance
                result = true;
            end
        end
        
        function CalculateAxesParametersByEnumeratingTimes(obj, setOfPoints, indices)
            indexOfSensor1 = indices(1);
            indexOfSensor2 = indices(2);
            indexOfSensor3 = indices(3);
            points1 = setOfPoints{indexOfSensor1};
            points2 = setOfPoints{indexOfSensor2};
            points3 = setOfPoints{indexOfSensor3};
            for index1 = 1:1:length(points1)
                time1 = points1{index1}.Time;
                for index2 = 1:1:length(points2)
                    time2 = points2{index2}.Time;
                    for index3 = 1:1:length(points3)
                        time3 = points3{index3}.Time;
                        times = [time1 time2 time3];
                        if IsDifferenceOfTimesGood(obj, indices, times) == true
                            params = obj.ransacCalculator.GetAxisParametersWithMinNumberOfPoints(indices, times, obj.minPointCount, obj.maxTubeDetlTime);
                            if ~isempty(params)
                                obj.resultSetOfParams{end+1,1} = params;
                            end
                        end                        
                    end
                end
            end
        end
        function result = IsDifferenceOfTimesGood(obj, indices, times)
            result = false;
            indexOfSensor1 = indices(1);
            indexOfSensor2 = indices(2);
            indexOfSensor3 = indices(3);
            time1 = times(1);
            time2 = times(2);
            time3 = times(3);
            if time2 < time3 && ...
               time1 < time2 && ...
               IsTimeDifferenceBetweenPointsGood(obj, indexOfSensor1, indexOfSensor2, time1, time2) && ...
               IsTimeDifferenceBetweenPointsGood(obj, indexOfSensor1, indexOfSensor3, time1, time2) && ...
               IsTimeDifferenceBetweenPointsGood(obj, indexOfSensor2, indexOfSensor3, time1, time2)
                result = true;
            end
        end
        function result = IsTimeDifferenceBetweenPointsGood(obj, indexOfSensor1, indexOfSensor2, time1, time2)
            result = false;
            maxDeltTime = abs(indexOfSensor1 - indexOfSensor2) * obj.maxDeltTimePerSensor;
            if maxDeltTime > abs(time1 - time2)
                result = true;
            end
        end





        


    end
end




