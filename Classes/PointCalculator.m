classdef PointCalculator < handle
    properties (Access = private)
        setOfPoints1 cell
        setOfPoints2 cell
        momentaryPhaseSeismogram ISeismogram
        absHilbertSeismogram ISeismogram
        setOfIntervals cell
        surfaceVelocity
        directWaveVelocity

        minTimesForPoints
        maxTimesForPoints
    end
    properties (Access = private, Constant)
        direction1 =  1;
        direction2 = -1;
%         distanceForPointCalculation = 1800
        minAmpOfMomentaryPhase = 0.6;
        maxFrequency = 60;
        offsetFromIntervalEdgesToRemovePoints = 4
        minHilbertAmplitudeLvlInInterval = 0.382
    end

    properties (Dependent)
        SetOfPoints1
        SetOfPoints2
        MomentaryPhaseSeismogram
        AbsHilbertSeismogram
        SetOfIntervals
        SurfaceVelocity
        DirectWaveVelocity
    end

    methods
        function obj = PointCalculator()
        end
        function setOfPoints1 = get.SetOfPoints1(obj)
            setOfPoints1 = obj.setOfPoints1;
        end
        function setOfPoints2 = get.SetOfPoints2(obj)
            setOfPoints2 = obj.setOfPoints2;
        end

        function set.MomentaryPhaseSeismogram(obj, seismogram)
            obj.momentaryPhaseSeismogram = seismogram;
        end
        function seismogram = get.MomentaryPhaseSeismogram(obj)
            seismogram = obj.momentaryPhaseSeismogram;
        end

        function set.AbsHilbertSeismogram(obj, seismogram)
            obj.absHilbertSeismogram = seismogram;
        end
        function seismogram = get.AbsHilbertSeismogram(obj)
            seismogram = obj.absHilbertSeismogram;
        end

        function set.SetOfIntervals(obj, setOfIntervals)
            obj.setOfIntervals = setOfIntervals;
        end
        function setOfIntervals = get.SetOfIntervals(obj)
            setOfIntervals = obj.setOfIntervals;
        end

        function set.SurfaceVelocity(obj, surfaceVelocity)
            obj.surfaceVelocity = surfaceVelocity;
        end
        function surfaceVelocity = get.SurfaceVelocity(obj)
            surfaceVelocity = obj.surfaceVelocity;
        end

        function set.DirectWaveVelocity(obj, directWaveVelocity)
            obj.directWaveVelocity = directWaveVelocity;
        end
        function directWaveVelocity = get.DirectWaveVelocity(obj)
            directWaveVelocity = obj.directWaveVelocity;
        end

        function Calculate(obj)
            CalculateMinAndMaxTimesForPoints(obj);
            obj.setOfPoints1 = cell(obj.momentaryPhaseSeismogram.NumberOfSensors,1);
            obj.setOfPoints2 = cell(obj.momentaryPhaseSeismogram.NumberOfSensors,1);
            for indexOfSensor = GetIndexOfBegSensor(obj):1:GetIndexOfEndSensor(obj)
                intervals = obj.setOfIntervals{indexOfSensor};
                momentaryPhaseSamples = GetAvailableMomentaryPhaseSamples(obj, indexOfSensor);
                [points1, points2] = CalculatePointsForIntervals(obj, intervals, momentaryPhaseSamples);
                obj.setOfPoints1{indexOfSensor} = points1;
                obj.setOfPoints2{indexOfSensor} = points2;
            end
        end
    end

    methods (Access = private)
        function CalculateMinAndMaxTimesForPoints(obj)
            CalculateMinTimesForPoints(obj);
            CalculateMaxTimesForPoints(obj);
        end
        function CalculateMinTimesForPoints(obj)
            directWaveTimes = obj.momentaryPhaseSeismogram.GetDirectTimesByVelocity(obj.directWaveVelocity);
            obj.minTimesForPoints = directWaveTimes;
        end
        function CalculateMaxTimesForPoints(obj)
            surfaceTimes = obj.momentaryPhaseSeismogram.GetDirectTimesByVelocity(obj.surfaceVelocity);
            obj.maxTimesForPoints = surfaceTimes;
        end
        function momentaryPhaseSamples = GetAvailableMomentaryPhaseSamples(obj, indexOfSensor)
            momentaryPhaseSamples = obj.momentaryPhaseSeismogram.Traces(indexOfSensor).Samples;
            minTimesForPoint = obj.minTimesForPoints(indexOfSensor);
            maxTimesForPoint = obj.maxTimesForPoints(indexOfSensor);
            momentaryPhaseSamples = RemoveSamplesLessThanMin(obj, momentaryPhaseSamples, minTimesForPoint);
            momentaryPhaseSamples = RemoveSamplesMoreThanMax(obj, momentaryPhaseSamples, maxTimesForPoint);
        end
        function samples = RemoveSamplesLessThanMin(obj, samples, minTimesForPoint)
            if minTimesForPoint > length(samples)
                minTimesForPoint = length(samples);
            end
            if minTimesForPoint > 1
                samples(1:minTimesForPoint) = 0;
            end
        end
        function samples = RemoveSamplesMoreThanMax(obj, samples, maxTimesForPoint)
            if maxTimesForPoint < 1
                maxTimesForPoint = 1;
            end
            if maxTimesForPoint < length(samples)
                samples(maxTimesForPoint:end) = 0;
            end
        end


        function indexOfBegSensor = GetIndexOfBegSensor(obj)
            indexOfBegSensor = ModelParameters.GetIndexOfBegSensor(obj.momentaryPhaseSeismogram);
        end
        function indexOfEndSensor = GetIndexOfEndSensor(obj)
            indexOfEndSensor = ModelParameters.GetIndexOfEndSensor(obj.momentaryPhaseSeismogram);
        end

        function [points1, points2] = CalculatePointsForIntervals(obj, intervals, momentaryPhaseSamples)
            momentaryPhaseTimes = GetGoodMaxAndMinTimesForMomentaryPhase(obj, momentaryPhaseSamples);
            momentaryPhaseTimes = SelectMomentaryPhaseTimesWithGoodFluctuations(obj, momentaryPhaseSamples, momentaryPhaseTimes);
            points1 = [];
            points2 = [];
            for i = 1:1:length(intervals)
                interval = intervals{i};
                if IsSearchingPointsInInterval(obj, interval) == true
                    newPoints1 = CalculatePointsForInterval(obj, interval, momentaryPhaseSamples, momentaryPhaseTimes, obj.direction1);
                    newPoints2 = CalculatePointsForInterval(obj, interval, momentaryPhaseSamples, momentaryPhaseTimes, obj.direction2);
                    points1 = [points1; newPoints1];
                    points2 = [points2; newPoints2];
                end
            end
        end
        function result = IsSearchingPointsInInterval(obj, interval)
            result = true;
            if interval.TypeOfInterval == IntervalType.Bad
                result = false;
            end
        end
        function momentaryPhaseTimes = GetGoodMaxAndMinTimesForMomentaryPhase(obj, momentaryPhaseSamples)
            momentaryPhaseTimes = GetAllMaxAndMinTimesForMomentaryPhase(obj, momentaryPhaseSamples);
            momentaryPhaseTimes = RemoveHighFrequencyFromTimes(obj, momentaryPhaseTimes);
            momentaryPhaseTimes = GetTimesWithAmplitudesMoreThanLvl(obj, momentaryPhaseTimes, momentaryPhaseSamples);
        end
        function momentaryPhaseTimes = GetAllMaxAndMinTimesForMomentaryPhase(obj, samples)
            momentaryPhaseTimes = [];
            for i = 2:1:length(samples)-1
                if ((samples(i) > samples(i-1) && samples(i) > samples(i+1)) || ...
                    (samples(i) < samples(i-1) && samples(i) < samples(i+1))) && ...
                    abs(samples(i)) > 5*10^-3
                    momentaryPhaseTimes(end+1,1) = i;
                end
            end            
        end
        function momentaryPhaseTimes = RemoveHighFrequencyFromTimes(obj, momentaryPhaseTimes)
            indices = GetIndicesOfGoodTimesByFrequency(obj, momentaryPhaseTimes);
            if isempty(indices)
                momentaryPhaseTimes = [];
            else
                momentaryPhaseTimes = momentaryPhaseTimes(indices);
            end
        end
        function indices = GetIndicesOfGoodTimesByFrequency(obj, times)
            indices = [];
            minHalfOfPeriod = round((1000 / obj.maxFrequency) / 2);
            countTimes = length(times);
            for i = 1:1:countTimes
                prevIndex = i - 1;
                nextIndex = i + 1;
                if (prevIndex > 0           && abs(times(prevIndex)-times(i)) >= minHalfOfPeriod) || ...
                   (nextIndex <= countTimes && abs(times(nextIndex)-times(i)) >= minHalfOfPeriod)
                    indices(end+1,1) = i;
                end
            end
        end
        function resultMomentaryPhaseTimes = GetTimesWithAmplitudesMoreThanLvl(obj, momentaryPhaseTimes, momentaryPhaseSamples)
            resultMomentaryPhaseTimes = [];
            if ~isempty(momentaryPhaseTimes)
                curMomentaryPhaseSamples = momentaryPhaseSamples(momentaryPhaseTimes);
                curMinAmplitude = obj.minAmpOfMomentaryPhase * max(abs(curMomentaryPhaseSamples));
                indicesOfTimes = find(abs(curMomentaryPhaseSamples) >= curMinAmplitude);
                if ~isempty(indicesOfTimes)
                    resultMomentaryPhaseTimes = momentaryPhaseTimes(indicesOfTimes); 
                end     
            end
        end


        function resultTimes = SelectMomentaryPhaseTimesWithGoodFluctuations(obj, momentaryPhaseSamples, momentaryPhaseTimes)
            resultTimes = [];
            for indexOfCentralTime = 2:1:length(momentaryPhaseTimes)-2
                if IsGoodTimeFluctuations(obj, momentaryPhaseSamples, momentaryPhaseTimes, indexOfCentralTime) == true
                    resultTimes(end+1,1) = momentaryPhaseTimes(indexOfCentralTime);
                end
            end
        end
        function result = IsGoodTimeFluctuations(obj, samples, times, indexOfCentralTime)
            result = false;
            prevTime = times(indexOfCentralTime-1);
            currTime = times(indexOfCentralTime);
            nextTime = times(indexOfCentralTime+1);
            if sign(samples(currTime)) == -1*sign(samples(prevTime)) || ...
               sign(samples(currTime)) == -1*sign(samples(nextTime))
                result = true;
            end
        end

        function points = CalculatePointsForInterval(obj, interval, samples, times, direction)
            points = [];
            timesInInterval = GetTimesInInterval(obj, times, interval);
            for i = 1:1:length(timesInInterval)
                currTime = timesInInterval(i);
                if IsTimeInGoodPartOfInterval(obj, currTime, interval) == true && ...
                   sign(samples(currTime)) == direction
                    newPoint = Point(interval.IndexOfTrace, currTime, direction, interval.TypeOfInterval);
                    newPoint = RecalculateTypeOfPointByHilbertEnvelope(obj, newPoint, interval);
                    points{end+1,1} = newPoint;
                end
            end
        end
        function timesInInterval = GetTimesInInterval(obj, times, interval)
            timesInInterval = [];
            indices = find(times >= interval.BeginTime & times <= interval.EndingTime);
            if ~isempty(indices)
                timesInInterval = times(indices);
            end
        end
        function result = IsTimeInGoodPartOfInterval(obj, currTime, interval)
            result = false;
            if (currTime > interval.BeginTime+obj.offsetFromIntervalEdgesToRemovePoints && ... 
                currTime < interval.EndingTime-obj.offsetFromIntervalEdgesToRemovePoints)
                result = true;
            end
        end
        function point = RecalculateTypeOfPointByHilbertEnvelope(obj, point, interval)
            if point.TypeOfPoint == PointType.Good
                absHilbertSamples = obj.absHilbertSeismogram.Traces(interval.IndexOfTrace).Samples;
                curAbsHilbertSamples = absHilbertSamples(interval.BeginTime:interval.EndingTime);
                minAmplitude = max(curAbsHilbertSamples) * obj.minHilbertAmplitudeLvlInInterval;
                curAmplitude = absHilbertSamples(point.Time);
                if curAmplitude < minAmplitude
                    point.TypeOfPoint = PointType.Additional;
                end
            end
        end

        function pointsFuncFiForOneSensor = GetMomentaryPhasePoints(obj, allTimesFuncFi, momentaryPhaseSamples, firstTime)
            pointsFuncFiForOneSensor = [];
            momentaryPhaseSamples = momentaryPhaseSamples / max(abs(momentaryPhaseSamples));            
            timesFuncFi = [];
            for i = 2:1:length(allTimesFuncFi)-2
                time = allTimesFuncFi(i);
                time1 = allTimesFuncFi(i-1);
                time2 = allTimesFuncFi(i+1);
                if (sign(momentaryPhaseSamples(time)) == -1*sign(momentaryPhaseSamples(time1)) || ... 
                    sign(momentaryPhaseSamples(time)) == -1*sign(momentaryPhaseSamples(time2))) && ...
                    time >= firstTime
                    timesFuncFi(end+1,1) = time;
                end
            end
        end
    end
end




