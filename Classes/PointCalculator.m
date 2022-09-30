classdef PointCalculator < handle
    properties (Access = private)
        setOfPoints1 cell
        setOfPoints2 cell
        momentaryPhaseSeismogram ISeismogram
        setOfIntervals cell
        surfaceVelocity
        directWaveVelocity
        numberSamplesPerSec
    end
    properties (Access = private, Constant)
        direction1 =  1;
        direction2 = -1;
        distanceForPointCalculation = 1800
        minAmpOfMomentaryPhase = 0.6;
    end

    properties (Dependent)
        SetOfPoints1
        SetOfPoints2
        MomentaryPhaseSeismogram
        SetOfIntervals
        SurfaceVelocity
        DirectWaveVelocity
        NumberSamplesPerSec
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

        function set.NumberSamplesPerSec(obj, numberSamplesPerSec)
            obj.numberSamplesPerSec = numberSamplesPerSec;
        end
        function numberSamplesPerSec = get.NumberSamplesPerSec(obj)
            numberSamplesPerSec = obj.numberSamplesPerSec;
        end

        function Calculate(obj)
            for indexOfSensor = GetIndexOfBegSensor(obj):1:GetIndexOfEndSensor(obj)
                intervals = obj.setOfIntervals{indexOfSensor};
                momentaryPhaseSamples = obj.momentaryPhaseSeismogram.Traces(indexOfSensor).Samples;
                [points1, points2] = CalculatePointsForIntervals(obj, intervals, momentaryPhaseSamples);
                obj.setOfPoints1{indexOfSensor} = points1;
                obj.setOfPoints2{indexOfSensor} = points2;
            end
        end
    end

    methods (Access = private)
        function indexOfBegSensor = GetIndexOfBegSensor(obj)
            indexOfCentralSensor = obj.momentaryPhaseSeismogram.IndexOfCentralSensor;
            distanceBetwenTwoSensors = obj.momentaryPhaseSeismogram.GetDistanceBetwenTwoSensors();
            sensorsForPointCalculation = round(obj.distanceForPointCalculation / distanceBetwenTwoSensors);
            indexOfBegSensor = indexOfCentralSensor - sensorsForPointCalculation;
            if indexOfBegSensor < 1
                indexOfBegSensor = 1;
            end
        end
        function indexOfEndSensor = GetIndexOfEndSensor(obj)
            indexOfCentralSensor = obj.momentaryPhaseSeismogram.IndexOfCentralSensor;
            distanceBetwenTwoSensors = obj.momentaryPhaseSeismogram.GetDistanceBetwenTwoSensors();
            sensorsForPointCalculation = round(obj.distanceForPointCalculation / distanceBetwenTwoSensors);
            indexOfEndSensor = indexOfCentralSensor + sensorsForPointCalculation;
            if indexOfEndSensor > obj.momentaryPhaseSeismogram.NumberOfSensors
                indexOfEndSensor = obj.momentaryPhaseSeismogram.NumberOfSensors;
            end
        end

        function [points1, points2] = CalculatePointsForIntervals(obj, intervals, momentaryPhaseSamples)
            points1 = [];
            points2 = [];
            for i = 1:1:length(intervals)
                interval = intervals{i};
                newPoints1 = CalculatePointsForInterval(obj, interval, momentaryPhaseSamples, obj.direction1);
                g = 1;
            end
        end
        function points = CalculatePointsForInterval(obj, interval, momentaryPhaseSamples, direction)

        end

        function pointsFuncFiForOneSensor = GetMomentaryPhasePoints(obj, allTimesFuncFi, momentaryPhaseSamples, firstTime)
            pointsFuncFiForOneSensor = [];
            momentaryPhaseSamples = momentaryPhaseSamples / max(abs(momentaryPhaseSamples));            
            timesFuncFi = [];
            for i = 2:1:length(allTimesFuncFi)-2
                time = allTimesFuncFi(i);
                time1 = allTimesFuncFi(i-1);
                time2 = allTimesFuncFi(i+1);
                if (sign(momentaryPhaseSamples(time)) == -1*sign(momentaryPhaseSamples(time1)) || sign(momentaryPhaseSamples(time)) == -1*sign(momentaryPhaseSamples(time2))) && ...
                    time >= firstTime
                    timesFuncFi(end+1,1) = time;
                end
            end
        end
    end
end




