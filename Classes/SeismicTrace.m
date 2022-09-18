classdef SeismicTrace < handle & matlab.mixin.Copyable
    properties (Access = private)
        samples (1,:) double = []
    end

    properties (Dependent)
        Samples
        NumberOfSamplesPerTrace
    end

    methods
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
        function firstTimeForTrace = CalculateFirstTime(obj, span, minTraceAmplitude)
            tr = smooth(obj.samples, span);
            t = 0;
            for j = 2:1:length(tr)-10
                At0 = tr(j-1);
                At1 = tr(j);
                At2 = tr(j+1);
                if minTraceAmplitude < max(abs(tr))*0.03
                    minTraceAmplitude = max(abs(tr))*0.03;
                end
                if abs(At1) > abs(At0) && abs(At1) > abs(At2) && abs(At1) > minTraceAmplitude
                    t = j;
                    break;
                elseif abs(At1) > abs(At0) && abs(At1) == abs(At2) && abs(At1) > minTraceAmplitude
                    trA = (tr(j:end));
                    ind0 = find(trA ~= At1);
                    if ~isempty(ind0)
                        ind1 = ind0(1);
                        if abs(At1) > abs(trA(ind1))
                            t = round(j+(ind1)/2-1);
                            break;
                        end
                    end
                end
            end
            firstTimeForTrace = t;
        end
    end

    methods (Access = public)
        function obj = SeismicTrace()
        end
    end

    methods (Access = private)
    end
end

