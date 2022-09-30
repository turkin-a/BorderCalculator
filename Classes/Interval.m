classdef Interval < handle
    properties (Access = private)
        beginTime (1,1) double
        endingTime (1,1) double
        typeOfInterval (1,1) IntervalType
        indexOfTrace (1,1) double
        frequency (1,1) double = 0
        dt
    end
    properties (Access = private, Constant)
        diapasonForTypeCalculation = 250;
        coefficientForGoodInterval = 1.5+0.15;
        coefficientForAdditionInterval = 1.50;
        delta = 0.618;
        gamma = 3.5
        span = 11;
    end

    properties (Dependent)
        BeginTime
        EndingTime
        TypeOfInterval
        IndexOfTrace
        Frequency
    end

    methods (Static)
        function [signal_cos, signal_sin] = GetImpulse(frequency, gamma, dt)
            lengthOfHalfImpulse = round((gamma/2)/(dt) / frequency);
            lengthOfImpulse = lengthOfHalfImpulse*2+1;
            w_f = 2 * pi * frequency;
            signal_sin = zeros(lengthOfImpulse,1);
            signal_cos = zeros(lengthOfImpulse,1);
            index = 1;    
            for t = -lengthOfHalfImpulse:1:lengthOfHalfImpulse
                if index >= 1 && index <= lengthOfImpulse
                    signal_sin(index) = sin(w_f*t*dt) * sech((w_f*t*dt)/gamma);
                    signal_cos(index) = cos(w_f*t*dt) * sech((w_f*t*dt)/gamma);
                end
                index = index + 1;
            end
        end
    end

    methods
        function obj = Interval(beginTime, endingTime, indexOfTrace, dt)
            obj.beginTime = beginTime;
            obj.endingTime = endingTime;
            obj.indexOfTrace = indexOfTrace;
            obj.dt = dt;
        end

        function beginTime = get.BeginTime(obj)
            beginTime = obj.beginTime;
        end

        function endingTime = get.EndingTime(obj)
            endingTime = obj.endingTime;
        end

        function typeOfInterval = get.TypeOfInterval(obj)
            typeOfInterval = obj.typeOfInterval;
        end

        function indexOfTrace = get.IndexOfTrace(obj)
            indexOfTrace = obj.indexOfTrace;
        end

        function frequency = get.Frequency(obj)
            frequency = obj.frequency;
        end

        function CalculateType(obj, trace, traceOfHilbert)
            CalculateTypeByHilbert(obj, traceOfHilbert);
            CalculateTypeByFrequency(obj, trace, traceOfHilbert);
        end
    end

    methods (Access = private)
        function CalculateTypeByHilbert(obj, traceOfHilbert)
            if IsIntervalChosen(obj, traceOfHilbert, obj.coefficientForGoodInterval)
                obj.typeOfInterval = IntervalType.Good;
            elseif IsIntervalChosen(obj, traceOfHilbert, obj.coefficientForAdditionInterval)
                obj.typeOfInterval= IntervalType.Additional;
            end
        end
        function result = IsIntervalChosen(obj, traceOfHilbert, coefficient)
            result = false;
            timesOfInterval = obj.beginTime:obj.endingTime;
            samplesOfHilbertInInterval = traceOfHilbert.Samples(timesOfInterval);
            indexOfMaxInInterval = find(samplesOfHilbertInInterval == max(samplesOfHilbertInInterval),1);
            curAmp = samplesOfHilbertInInterval(indexOfMaxInInterval);
            minAmplitude = GetMinAmplitudeOfHilbert(obj, samplesOfHilbertInInterval, indexOfMaxInInterval, coefficient);
            if curAmp >= minAmplitude
                result = true;
            end
        end
        function resultAmplitude = GetMinAmplitudeOfHilbert(obj, samplesOfHilbertInInterval, centerTime, coefficient)
            begTime = centerTime - obj.diapasonForTypeCalculation;
            endTime = centerTime + obj.diapasonForTypeCalculation;
            if begTime < 1
                begTime = 1;
            end
            if endTime > length(samplesOfHilbertInInterval)
                endTime = length(samplesOfHilbertInInterval);
            end
            curSemplesOfHilbert = samplesOfHilbertInInterval(begTime:endTime);
            curAbsSemplesOfHilbert = abs(curSemplesOfHilbert);
            medianAmp = median(curAbsSemplesOfHilbert);
            resultAmplitude = coefficient * medianAmp;
        end

        function CalculateTypeByFrequency(obj, trace, traceOfHilbert)
            intervalFrequencyCalculator = IntervalFrequencyCalculator();
            obj.frequency = intervalFrequencyCalculator.Calculate(obj, trace);
            MarkTypeByFrequency(obj, trace, traceOfHilbert);
        end
        function MarkTypeByFrequency(obj, trace, traceOfHilbert)
            MarkTypeWithoutFrequency(obj);
            if obj.frequency > 0 && ~isempty(trace) && ~isempty(traceOfHilbert)
                alfa1 = obj.delta;
                maxOfCorrelation1 = GetMaxOfCorrelation(obj, trace, alfa1);
                alfa2 = 1;
                maxOfCorrelation2 = GetMaxOfCorrelation(obj, trace, alfa2);
                alfa3 = (2-obj.delta);
                maxOfCorrelation3 = GetMaxOfCorrelation(obj, trace, alfa3);
                
                correlationTimes = CombineCorrelation(obj, maxOfCorrelation1, maxOfCorrelation2, maxOfCorrelation3);
                MarkTypeByMaxOfCorrelation(obj, correlationTimes, traceOfHilbert);
            end
        end
        function MarkTypeWithoutFrequency(obj)
            if obj.typeOfInterval == IntervalType.Good && obj.frequency == 0
                obj.typeOfInterval = IntervalType.Additional;
            end
        end
        function maxOfCorrelation = GetMaxOfCorrelation(obj, trace, alfa)
            correlation = GetCorrelationForInterval(obj, trace, alfa);
            indexOfMaxCorrelation = find(correlation == max(correlation));
            maxOfCorrelation = (obj.beginTime-1) + indexOfMaxCorrelation(1);
        end
        function correlation = GetCorrelationForInterval(obj, trace, alfa)
            curFrequency = obj.frequency * alfa;
            [signal_cos, signal_sin] = Interval.GetImpulse(curFrequency, obj.gamma, obj.dt);
            correlation = CalculateCorrelation(obj, trace, signal_cos, signal_sin);
            correlation = smooth(correlation, obj.span);
        end
        function correlationSamples = CalculateCorrelation(obj, trace, signal_cos, signal_sin)
            correlationSamples = zeros(obj.endingTime-obj.beginTime+1,1);
            halfLength = (length(signal_cos)-1)/2;
            i = 1;
            for centerTime = obj.beginTime:1:obj.endingTime
                curSamples = CutSamplesByLength(obj, centerTime, halfLength, trace);
                sinCorrelation = corr(curSamples, signal_sin);
                cosCorrelation = corr(curSamples, signal_cos);
                resultCorrelation = sqrt(sinCorrelation^2 + cosCorrelation^2);
                correlationSamples(i) = resultCorrelation;
                i = i + 1;
            end
        end
        % Срезание до симетрии относительно centerTime
        function curSamples = CutSamplesByLength(obj, centerTime, halfLength, trace)
            curSamples = zeros(halfLength*2+1,1);
            tBeg = centerTime - halfLength;
            tEnd = centerTime + halfLength;
            tRealBeg = tBeg;
            tRealEnd = tEnd;
            if tRealBeg < 1
                tRealBeg = 1;
            end
            if tRealEnd > trace.NumberOfSamplesPerTrace
                tRealEnd = trace.NumberOfSamplesPerTrace;
            end
            begOffset = abs(tRealBeg - tBeg);
            endOffset = abs(tRealEnd - tEnd);
            curSamples(1+begOffset:end-endOffset) = trace.Samples(tRealBeg:tRealEnd);
        end
        function correlationTimes = CombineCorrelation(obj, maxOfCorrelation1, maxOfCorrelation2, maxOfCorrelation3)
            correlationTimes = [maxOfCorrelation1;
                                maxOfCorrelation2;
                                maxOfCorrelation3];
            correlationTimes = unique(correlationTimes, 'sorted');
            correlationTimes = correlationTimes(correlationTimes > 0);
        end
        function MarkTypeByMaxOfCorrelation(obj, correlationTimes, traceOfHilbert)
            if ~isempty(correlationTimes)
                if obj.typeOfInterval == IntervalType.Good
                    indicesTimesInInterval = find(correlationTimes > obj.beginTime & correlationTimes < obj.endingTime);
                    if ~isempty(indicesTimesInInterval)
                        curSamplesOfHilbert = traceOfHilbert.Samples(obj.beginTime:obj.endingTime);
                        indOfMaxHilbert = find(curSamplesOfHilbert == max(curSamplesOfHilbert),1);
                        timeOfMaxHilbert = indOfMaxHilbert + (obj.beginTime-1);
                        correlationTimesInInterval = correlationTimes(indicesTimesInInterval);
                        maxTimeDistance = (obj.endingTime - obj.beginTime) / (obj.gamma) / 2;
                        ind1 = find(correlationTimesInInterval > timeOfMaxHilbert-maxTimeDistance & correlationTimesInInterval < timeOfMaxHilbert+maxTimeDistance, 1);
                        if isempty(ind1)
                            obj.typeOfInterval = IntervalType.Additional;
                        end
                    else
                        obj.typeOfInterval= IntervalType.Additional;
                    end
                end
            end
        end
        

    end
end





