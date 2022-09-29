classdef SeismicTrace < handle & matlab.mixin.Copyable
    properties (Access = private)
        samples (1,:) double = []
    end

    properties (Dependent)
        Samples
        NumberOfSamplesPerTrace
    end

    methods
        function obj = SeismicTrace()
        end

        function set.Samples(obj, samples)
            obj.samples = samples;
        end
        function samples = get.Samples(obj)
            samples = obj.samples;
        end

        function numberOfSamplesPerTrace = get.NumberOfSamplesPerTrace(obj)
            numberOfSamplesPerTrace = length(obj.samples);
        end

        % Найти первое вступление на трассе
        function firstTimeForTrace = CalculateAndGetFirstTime(obj, span, minTraceAmplitudePercent)
            firstTimeForTrace = 0;
            curSamples = smooth(obj.samples, span);
            minTraceAmplitude = GetMinTraceAmplitude(obj, minTraceAmplitudePercent);
            for time = 2:1:length(curSamples)-10
                if IsThisSampleFirstImpulse(obj, curSamples, time, minTraceAmplitude) == true
                    firstTimeForTrace = time;
                    break;
                end
                if IsThisSeveralAmpForFirstImpulse(obj, curSamples, time, minTraceAmplitude) == true
                    trA = (curSamples(time:end));
                    AmplitudeForTime1 = curSamples(time);
                    ind0 = find(trA ~= AmplitudeForTime1);
                    if ~isempty(ind0)
                        ind1 = ind0(1);
                        if abs(AmplitudeForTime1) > abs(trA(ind1))
                            firstTimeForTrace = round(time+(ind1)/2-1);
                            break;
                        end
                    end
                end

            end
        end

        function [maxTimes, minTimes] = GetTimesOfMaxAndMinAmplitudes(obj, firstTime)
            maxTimes = [];
            minTimes = firstTime;
            begTime = max([firstTime 3]);
            endTime = length(obj.samples)-2;
            for index = begTime:1:endTime
                if IsSampleLocalMaximumWithIndex(obj, index)
                    maxTimes(end+1,1) = index;
                end
                if IsSampleLocalMinimumWithIndex(obj, index)
                    minTimes(end+1,1) = index;
                end
            end
            minTimes(end+1,1) = length(obj.samples);
        end
    end

    methods (Access = private)
        function result = IsSampleLocalMaximumWithIndex(obj, index)
            result = false;
            if (obj.samples(index) > obj.samples(index-1)  && obj.samples(index) > obj.samples(index+1)) || ...
               (obj.samples(index) >= obj.samples(index-1) && obj.samples(index) > obj.samples(index-2)  && ...
                obj.samples(index) >= obj.samples(index+1) && obj.samples(index) > obj.samples(index+2))
                result = true;
            end
        end
        function result = IsSampleLocalMinimumWithIndex(obj, index)
            result = false;
            if (obj.samples(index) < obj.samples(index-1)  && obj.samples(index) < obj.samples(index+1)) || ...
               (obj.samples(index) <= obj.samples(index-1) && obj.samples(index) < obj.samples(index-2)  && ...
                obj.samples(index) <= obj.samples(index+1) && obj.samples(index) < obj.samples(index+2))
                result = true;
            end
        end

        function minTraceAmplitude = GetMinTraceAmplitude(obj, minTraceAmplitudePercent)
            if minTraceAmplitudePercent < max(abs(obj.samples)) * minTraceAmplitudePercent
                minTraceAmplitude = max(abs(obj.samples)) * minTraceAmplitudePercent;
            else
                minTraceAmplitude = minTraceAmplitudePercent;
            end
        end
        function result = IsThisSampleFirstImpulse(obj, curSamples, time, minTraceAmplitude)
            result = false;
            AmplitudeForTime0 = curSamples(time-1);
            AmplitudeForTime1 = curSamples(time);
            AmplitudeForTime2 = curSamples(time+1);
            if abs(AmplitudeForTime1) > abs(AmplitudeForTime0) && ... 
               abs(AmplitudeForTime1) > abs(AmplitudeForTime2) && ...
               abs(AmplitudeForTime1) > minTraceAmplitude
                result = true;
            end
        end
        function result = IsThisSeveralAmpForFirstImpulse(obj, curSamples, time, minTraceAmplitude)
            result = false;
            AmplitudeForTime0 = curSamples(time-1);
            AmplitudeForTime1 = curSamples(time);
            AmplitudeForTime2 = curSamples(time+1);
            if abs(AmplitudeForTime1) >  abs(AmplitudeForTime0) && ...
               abs(AmplitudeForTime1) == abs(AmplitudeForTime2) && ...
               abs(AmplitudeForTime1) > minTraceAmplitude
                result = true;
            end
        end
    end
end

