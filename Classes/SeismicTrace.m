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
        function firstTimeForTrace = CalculateFirstTime(obj, span, minTraceAmplitudePercent)
            firstTimeForTrace = 0;
            curSamples = smooth(obj.samples, span);
            minTraceAmplitude = GetMinTraceAmplitude(obj, minTraceAmplitudePercent);
            for time = 2:1:length(curSamples)-10
                if IsThisSampleFirstImpulse(obj, curSamples, time, minTraceAmplitude) == true
                    firstTimeForTrace = time;
                    break;
                end

                if abs(AmplitudeForTime1) > abs(AmplitudeForTime0) && abs(AmplitudeForTime1) == abs(AmplitudeForTime2) && abs(AmplitudeForTime1) > minTraceAmplitude
                    trA = (curSamples(time:end));
                    ind0 = find(trA ~= AmplitudeForTime1);
                    if ~isempty(ind0)
                        ind1 = ind0(1);
                        if abs(AmplitudeForTime1) > abs(trA(ind1))
                            firstImpulseTime = round(time+(ind1)/2-1);
                            break;
                        end
                    end
                end

            end
%             firstTimeForTrace = firstImpulseTime;
        end
    end

    methods (Access = private)
        function minTraceAmplitude = GetMinTraceAmplitude(obj, minTraceAmplitudePercent)
            if minTraceAmplitudePercent < max(abs(tr)) * minTraceAmplitudePercent
                minTraceAmplitude = max(abs(tr)) * minTraceAmplitudePercent;
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
    end
end

