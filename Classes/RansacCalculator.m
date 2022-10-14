classdef RansacCalculator < handle
    properties (Access = private)
        setOfPoints cell
        tableOfTimeSensor
        
        indexOfBegSensor
        indexOfEndSensor
        indexOfCentralSensor
        numberOfSensors
        numberOfSamplesPerTrace

        Li
        directWaveVelocity
        dt
        firstTimes
    end

    properties (Access = private, Constant)
        maxOffsetX = 100
        maxAbsFi = 30
    end

    properties(Dependent)
    end

    methods
        function obj = RansacCalculator(seismogram, directWaveVelocity)
            obj.indexOfBegSensor = ModelParameters.GetIndexOfBegSensor(seismogram);
            obj.indexOfEndSensor = ModelParameters.GetIndexOfEndSensor(seismogram);
            obj.indexOfCentralSensor = seismogram.IndexOfCentralSensor;
            obj.numberOfSensors = seismogram.NumberOfSensors;
            obj.numberOfSamplesPerTrace = seismogram.NumberOfSamplesPerTrace;

            obj.Li = seismogram.GetDistancesFromSource();
            obj.directWaveVelocity = directWaveVelocity;
            obj.dt = 1 / seismogram.NumberSamplesPerSec;
            obj.firstTimes = seismogram.FirstTimes;
        end
        function tableOfTimeSensor = GetTableOfAllPointParameters(obj, setOfPoints)
            obj.setOfPoints = setOfPoints;
            obj.tableOfTimeSensor = [];
            for indexOfSensor = 1:1:length(setOfPoints)
                points = obj.setOfPoints{indexOfSensor};
                    if ~isempty(points)
                        AppendAllPointsToTable(obj, points);
                    end
            end
            tableOfTimeSensor = obj.tableOfTimeSensor;
        end

        function resultParameters = GetAxisParametersWithMinNumberOfPoints(obj, indices, times, minPointCount, maxTubeDetlTime)
            resultParameters = [];
            [axisParameters] = GetAxisParametersByThreePoints(obj, times, indices);
            if ~isempty(axisParameters)
                if IsCountOfPointsInTubeGood(obj, axisParameters, minPointCount, maxTubeDetlTime)
                    resultParameters = axisParameters;
                end
            end
        end        

    end

    methods(Access = private)
        function AppendAllPointsToTable(obj, points)
            for i = 1:1:length(points)
                point = points{i};
                tableLine = [point.Time point.IndexOfSensor double(point.TypeOfPoint) point.Direction];
                obj.tableOfTimeSensor = [obj.tableOfTimeSensor; tableLine];
            end
        end

        function [axisParameters] = GetAxisParametersByThreePoints(obj, times, indices)
            axisParameters = [];
            t1 = times(1);
            t2 = times(2);
            t3 = times(3);
            x1 = obj.Li(indices(1));
            x2 = obj.Li(indices(2));
            x3 = obj.Li(indices(3));
            [v, h] = GetVelocityAndH(obj, t1, t2, t3, x1, x2, x3);
            if isempty(v) || isempty(h)
                return;
            end            
            
            fi = GetFiAngle(obj, t1, t2, t3, x1, x2, x3);
            if isempty(fi)
                return;
            end

            if IsMinXOfAxisGood(obj, h, fi) == false || ...
               IsMinTimeOfAxisGood(obj, h, fi, v) == false || ...
               IsVelocityGood(obj, h, fi, v) == false
                return;
            end
            
            times = GetGoodTimesForAxisByH_Fi_V(obj, h, fi, v);
            if isempty(times)
                return;
            end
            
            axisParameters = AxisParameters();
            axisParameters.V = v;
            axisParameters.H = h;
            axisParameters.Fi = fi;
        end
        function [v, h] = GetVelocityAndH(obj, t1, t2, t3, x1, x2, x3)
            v = [];
            h = [];
            v_2 = ((x3-x2) * (x3-x1) * (x2-x1)) / (x2*(t3^2-t1^2) - x3*(t2^2-t1^2) - x1*(t3^2-t2^2));
            h_2 = (t3^2*(x2-x1)*x2*x1 - t2^2*(x3-x1)*x3*x1 + t1^2*(x3-x2)*x3*x2) / (x2*(t3^2-t1^2) - x3*(t2^2-t1^2) - x1*(t3^2-t2^2));
            if v_2 < 0 || h_2 < 0
                return;
            end
            v = sqrt(v_2) / obj.dt;
            h = sqrt(h_2) / 2;
        end
        function resultFi = GetFiAngle(obj, t1, t2, t3, x1, x2, x3)
            resultFi = [];
            tmp1 = x2^2*(t3^2-t1^2) - x3^2*(t2^2-t1^2) - x1^2*(t3^2-t2^2);
            tmp2 = x2*(t3^2-t1^2) - x3*(t2^2-t1^2) - x1*(t3^2-t2^2);
            tmp3 = t3^2*(x2-x1)*x2*x1 - t2^2*(x3-x1)*x3*x1 + t1^2*(x3-x2)*x3*x2;
            sinFi = (1 / 2) * tmp1 / sqrt(tmp2 * tmp3);
            if abs(sinFi) > 1
                return;
            end
            if IsOnLeft(obj, x1, x2, x3)
                fi = asind(sinFi);
            else
                fi = -asind(sinFi);
            end
            if abs(fi) <= obj.maxAbsFi
                resultFi = fi;
            end
        end
        function result = IsOnLeft(obj, x1, x2, x3)
            if (x1 <= 0 && x2 < 0 && x3 < 0)
                result = true;
            elseif (x1 >= 0 && x2 > 0 && x3 > 0)
                result = false;
            else
                errID = 'RansacCalculator:IsOnLeft:PointsAreInDifferentSides';
                msgtext = 'All x must be positive or negative.';
                ME = MException(errID,msgtext);
                throw(ME);
            end
        end
        function result = IsMinXOfAxisGood(obj, h, fi)
            result = true;
            minX = GetMinXOfAxis(obj, h, fi);
            if abs(minX) > obj.maxOffsetX
                result = false;
            end
        end
        function minX = GetMinXOfAxis(obj, h, fi)
            minX = -2 * h * sind(fi);
        end
        function result = IsMinTimeOfAxisGood(obj, h, fi, v)
            result = true;
            minTime = GetMinTimeOfAxis(obj, h, fi, v);
            if minTime > obj.numberOfSamplesPerTrace || minTime < 1
                result = false;
            end
        end
        function minTime = GetMinTimeOfAxis(obj, h, fi, v)
            minTime =  ((2*h / v) * cosd(fi)) / obj.dt;
        end
        function result = IsVelocityGood(obj, h, fi, v)
            result = true;
            minTime = GetMinTimeOfAxis(obj, h, fi, v);
            [minV, maxV] = GetVelocityIntervalForTime(obj, minTime);
            if v < minV || v > maxV
                result = false;
            end
        end
        function [minV, maxV] = GetVelocityIntervalForTime(obj, minTime)
            increaseVelocity = minTime / 3;
            minV = (0.90) * obj.directWaveVelocity + increaseVelocity;
            maxV = (1.25) * obj.directWaveVelocity + increaseVelocity;
        end

        function resultTimes = GetGoodTimesForAxisByParams(obj, axisParameters)
            resultTimes = GetGoodTimesForAxisByH_Fi_V(obj, axisParameters.H, axisParameters.Fi, axisParameters.V);
        end
        function resultTimes = GetGoodTimesForAxisByH_Fi_V(obj, h, fi, v)
            resultTimes = [];
            times = Axis.GetTimesByH_Fi_V(h, fi, v, obj.Li, obj.dt);
            if IsTimesOfAxisGood(obj, times) == false
                return;
            end
            resultTimes = times;
        end
        function result = IsTimesOfAxisGood(obj, times)
            result = true;
            deltTimes = times - obj.firstTimes;
            IsAxisBendDirectionCorrect(obj, times);
            if times(1) > obj.numberOfSamplesPerTrace || ...
               times(end) > obj.numberOfSamplesPerTrace || ...
               min(deltTimes) < 0
                result = false;
            end
        end
        function result = IsAxisBendDirectionCorrect(obj, times)
            result = true;
            sensorIndices = 1:obj.numberOfSensors;
            pnAll = polyfit(sensorIndices, times, 2);
            pn2 = pnAll(1); 
            if ~isreal(pn2) || pn2 < 0
                result = false;
            end
        end

        function result = IsCountOfPointsInTubeGood(obj, axisParameters, minPointCount, maxTubeDetlTime)
            result = false;
            resultIndices = GetIndicesOfSensorsInTube(obj, axisParameters, maxTubeDetlTime);
            if length(resultIndices) >= minPointCount
                result = true;
            end
        end
        function resultIndices = GetIndicesOfSensorsInTube(obj, axisParameters, maxTubeDetlTime)
            times = GetGoodTimesForAxisByParams(obj, axisParameters);
            sensorIndices = 1:obj.numberOfSensors;
            resultIndices = [];
            for it = 1:length(sensorIndices) 
                indicesOfSensor = find(obj.tableOfTimeSensor(:,2) == sensorIndices(it));
                if ~isempty(indicesOfSensor)
                    [absOffsetOfMin,indexOfMin] = min(abs(obj.tableOfTimeSensor(indicesOfSensor,1)- times(it)));
                    if absOffsetOfMin < maxTubeDetlTime
                        resultIndices = [resultIndices; indicesOfSensor(indexOfMin)];               
                    end
                end
            end
        end


    end

end