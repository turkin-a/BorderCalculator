classdef IntervalsCalculator < handle
    properties (Access = private)
        seismogram ISeismogram
        correctedAbsHilbertSeismogram ISeismogram
%         numberSamplesPerSec double
        directWaveVelocity double
        surfaceVelocity double

        setOfMaxTimes
        setOfMinTimes
        setOfIntervals (:,1) cell
    end
    properties (Access = private, Constant)
        gamma = 3.5
        minAmpRatioToCombine = 0.50;
    end

    properties (Dependent)
        Seismogram
        CorrectedAbsHilbertSeismogram
        DirectWaveVelocity
        SurfaceVelocity
%         NumberSamplesPerSec
        SetOfIntervals
    end

    methods
        function obj = IntervalsCalculator()
        end

        function SetParameters(obj, analyticalSignal, indexOfSeism)
            obj.correctedSeismogram = analyticalSignal.CorrectedSeismicData.Seismograms(indexOfSeism);
            obj.hilbertSeismogram = analyticalSignal.HilbertSeismicData.Seismograms(indexOfSeism);
        end

        function set.Seismogram(obj, seismogram)
            obj.seismogram = seismogram;
        end
        function seismogram = get.Seismogram(obj)
            seismogram = obj.seismogram;
        end

        function set.CorrectedAbsHilbertSeismogram(obj, correctedAbsHilbertSeismogram)
            obj.correctedAbsHilbertSeismogram = correctedAbsHilbertSeismogram;
        end
        function correctedAbsHilbertSeismogram = get.CorrectedAbsHilbertSeismogram(obj)
            correctedAbsHilbertSeismogram = obj.correctedAbsHilbertSeismogram;
        end

        function set.DirectWaveVelocity(obj, directWaveVelocity)
            obj.directWaveVelocity = directWaveVelocity;
        end
        function directWaveVelocity = get.DirectWaveVelocity(obj)
            directWaveVelocity = obj.directWaveVelocity;
        end

        function set.SurfaceVelocity(obj, surfaceVelocity)
            obj.surfaceVelocity = surfaceVelocity;
        end
        function surfaceVelocity = get.SurfaceVelocity(obj)
            surfaceVelocity = obj.surfaceVelocity;
        end

%         function set.NumberSamplesPerSec(obj, numberSamplesPerSec)
%             obj.numberSamplesPerSec = numberSamplesPerSec;
%         end
%         function numberSamplesPerSec = get.NumberSamplesPerSec(obj)
%             numberSamplesPerSec = obj.numberSamplesPerSec;
%         end

        function setOfIntervals = get.SetOfIntervals(obj)
            setOfIntervals = obj.setOfIntervals;
        end

        function Calculate(obj)
            CalculateSetsOfMaxAndMinTimes(obj);
            BuildSetOfIntervals(obj);
            CalculateSetsOfTypeOfIntervals(obj);
        end
    end

    methods (Access = private)
        function CalculateSetsOfMaxAndMinTimes(obj)
            [obj.setOfMaxTimes, obj.setOfMinTimes] = obj.correctedAbsHilbertSeismogram.GetSetsOfTimesOfMaxAndMinAmplitudes();

            TesterVisualizer.SetMaxAndMinHilbertTimes(obj.setOfMaxTimes, obj.setOfMinTimes);
        end

        function BuildSetOfIntervals(obj)
            obj.setOfIntervals = cell(obj.seismogram.NumberOfSensors,1);
            for indexOfSensor = 1:1:obj.seismogram.NumberOfSensors
                intervals = GetIntervalsForTrace(obj, indexOfSensor);
                obj.setOfIntervals{indexOfSensor} = intervals;
            end
        end

        function intervals = GetIntervalsForTrace(obj, indexOfSensor)
            if indexOfSensor == obj.seismogram.IndexOfCentralSensor
                intervals = [];
            else
                firstTime = obj.seismogram.FirstTimes(indexOfSensor);
                maxTimes = GetValuesMoreThen(obj, obj.setOfMaxTimes{indexOfSensor}, firstTime);
                minTimes = GetValuesMoreThen(obj, obj.setOfMinTimes{indexOfSensor}, firstTime);
                intervals = BuildIntervalsForTrace(obj, maxTimes, minTimes, indexOfSensor);
    
                samplesOfHilbert = obj.correctedAbsHilbertSeismogram.Traces(indexOfSensor).Samples;
                intervals = CombineIntervalsOfPulseEnvelope(obj, intervals, samplesOfHilbert);
            end
        end

        function resultValues = GetValuesMoreThen(obj, values, minNumber)
            resultValues = [];
            minNumber = max([minNumber 1]);
            ind = find(values >= minNumber);
            if ~isempty(ind)
                resultValues = values(ind);
            end
        end
        function intervals = BuildIntervalsForTrace(obj, maxTimes, minTimes, indexOfTrace)
            intervals = [];
            count = 0;
            dt = 1 / obj.seismogram.NumberSamplesPerSec;
            for i = 1:1:length(minTimes)-1
                min1 = minTimes(i);
                min2 = minTimes(i+1);
                if ~isempty(maxTimes)
                    ind = find(maxTimes > min1 & maxTimes < min2, 1);
                    if ~isempty(ind)
                        count = count + 1;
                        intervals{count,1} = Interval(min1, min2, indexOfTrace, dt);
                    end
                end
            end
        end

        function intervals = CombineIntervalsOfPulseEnvelope(obj, intervals, samplesOfHilbert)
            while true
                ampRatios = GetAmplitudeRatioOfIntervals(obj, samplesOfHilbert, intervals);
                [intervals, isComdined] = CombineTwoCloseIntervalsOfPulseEnvelope(obj, intervals, ampRatios);
                if isComdined == false
                    break;
                end
            end
        end
        function ampRatios = GetAmplitudeRatioOfIntervals(obj, samplesOfHilbert, intervals)
            numberOfIntervals = length(intervals);
            ampRatios = zeros(numberOfIntervals,2);
            samplesOfHilbert = samplesOfHilbert / max(samplesOfHilbert);
            for i = 1:1:numberOfIntervals
                interval = intervals{i};
                time1 = interval.BeginTime;
                time2 = interval.EndingTime;
                try
                ampRatios(i,1) = samplesOfHilbert(time1) / max(samplesOfHilbert(time1:time2));
                catch
                    h = 1;
                end
                ampRatios(i,2) = samplesOfHilbert(time2) / max(samplesOfHilbert(time1:time2));
            end
        end
        function [intervals, isComdined] = CombineTwoCloseIntervalsOfPulseEnvelope(obj, intervals, ampRatios)
            isComdined = false;
            if size(ampRatios,1) < 2
                return;
            end
            for index1 = 1:1:size(ampRatios,1)-1
                index2 = index1 + 1;
                ampRatio1 = ampRatios(index1,2);
                ampRatio2 = ampRatios(index2,1);
                if ampRatio1 > obj.minAmpRatioToCombine && ampRatio2 > obj.minAmpRatioToCombine
                    dt = 1 / obj.seismogram.NumberSamplesPerSec;
                    newInterval = Interval(intervals{index1}.BeginTime, ...
                                           intervals{index2}.EndingTime, ...
                                           intervals{index1}.IndexOfTrace, ...
                                           dt);
                    intervals{index1} = newInterval;
                    intervals(index1+1) = [];
                    isComdined = true;
                    return;
                end
            end
        end

        function CalculateSetsOfTypeOfIntervals(obj)
            for indexOfSensor = 1:1:obj.seismogram.NumberOfSensors
                intervals = obj.setOfIntervals{indexOfSensor};
                traceOfHilbert = obj.correctedAbsHilbertSeismogram.Traces(indexOfSensor);
                trace = obj.seismogram.Traces(indexOfSensor);
                for i = 1:1:length(intervals)
                    interval = intervals{i};
                    interval.CalculateType(trace, traceOfHilbert);
                end
            end
        end
    end
end