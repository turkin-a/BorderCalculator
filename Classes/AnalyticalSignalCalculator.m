classdef AnalyticalSignalCalculator < handle
    properties (Access = private)
        seismicData SeismicData
        analyticalSignal AnalyticalSignal
    end
    properties (Access = private, Constant)
        spanForCorrectSeismicData = 5
        spanForSmoothHilbertSamples = 30
        numberOfSmoothIteration = 9
    end

    properties (Dependent)
        AnalyticalSignalResult
    end

    methods
        function obj = AnalyticalSignalCalculator(seismicData)
            obj.seismicData = seismicData;
        end

        function Calculate(obj)
            obj.analyticalSignal = AnalyticalSignal();
            obj.analyticalSignal.CorrectedSeismicData = CalculateCorrectedSeismicData(obj);
            obj.analyticalSignal.HilbertSeismicData = CalculateHilbertSeismicData(obj, obj.seismicData);
            obj.analyticalSignal.CorrectedAbsHilbertSeismicData = CalculateCorrectedAbsHilbertSeismicData(obj, obj.analyticalSignal.HilbertSeismicData);
            obj.analyticalSignal.MomentaryPhaseSeismicData = CalculateMomentaryPhaseSeismicData(obj, obj.analyticalSignal.HilbertSeismicData);
        end

        function analyticalSignal = get.AnalyticalSignalResult(obj)
            analyticalSignal = obj.analyticalSignal;
        end
    end

    methods (Access = private)
        % CorrectedSeismicData
        function correctedSeismicData = CalculateCorrectedSeismicData(obj)
            correctedSeismicData = copy(obj.seismicData);
            CorrectSeismicData(obj, correctedSeismicData);
        end
        function CorrectSeismicData(obj, correctingSeismicData)
            for i = 1:1:correctingSeismicData.NumberOfSeismograms
                correctingSeismogram = correctingSeismicData.Seismograms(i);
                CorrectSeismogram(obj, correctingSeismogram);
            end
        end
        function CorrectSeismogram(obj, correctingSeismogram)
            for i = 1:1:correctingSeismogram.NumberOfSensors
                correctingTrace = correctingSeismogram.Traces(i);
                CorrectTrace(obj, correctingTrace);
            end
        end
        function CorrectTrace(obj, correctingTrace)
            samples = correctingTrace.Samples;
            samples = smooth(samples, obj.spanForCorrectSeismicData);
            correctingTrace.Samples = samples;
        end

        % HilbertSeismicData
        function hilbertSeismicData = CalculateHilbertSeismicData(obj, seismicData)
            hilbertSeismicData = copy(seismicData);
            ConvertToHilbertSeismicData(obj, hilbertSeismicData);
        end
        function ConvertToHilbertSeismicData(obj, seismicData)
            for i = 1:1:seismicData.NumberOfSeismograms
                seismogram = seismicData.Seismograms(i);
                ConvertToHilbertSeismogram(obj, seismogram);
            end
        end
        function ConvertToHilbertSeismogram(obj, seismogram)
            for i = 1:1:seismogram.NumberOfSensors
                trace = seismogram.Traces(i);
                ConvertToHilbertTrace(obj, trace);
            end
        end
        function ConvertToHilbertTrace(obj, trace)
            samples = trace.Samples;
            hilbertSamples = hilbert(samples);
            trace.Samples = hilbertSamples;
        end

        % CorrectedAbsHilbertSeismicData
        function correctedAbsHilbertSeismicData = CalculateCorrectedAbsHilbertSeismicData(obj, hilbertSeismicData)
            correctedAbsHilbertSeismicData = copy(hilbertSeismicData);
            ConvertToCorrectedAbsHilbertSeismicData(obj, correctedAbsHilbertSeismicData);
        end
        function ConvertToCorrectedAbsHilbertSeismicData(obj, hilbertSeismicData)
            for i = 1:1:hilbertSeismicData.NumberOfSeismograms
                hilbertSeismogram = hilbertSeismicData.Seismograms(i);
                ConvertToCorrectedAbsHilbertSeismogram(obj, hilbertSeismogram);
            end
        end
        function ConvertToCorrectedAbsHilbertSeismogram(obj, hilbertSeismogram)
            for i = 1:1:hilbertSeismogram.NumberOfSensors
                hilbertTrace = hilbertSeismogram.Traces(i);
                ConvertToCorrectedAbsHilbertTrace(obj, hilbertTrace);
            end
        end
        function ConvertToCorrectedAbsHilbertTrace(obj, hilbertTrace)
            hilbertSamples = hilbertTrace.Samples;
            absHilbertSamples = GetSmoothHilbertSamples(obj, hilbertSamples);
            hilbertTrace.Samples = absHilbertSamples;
        end
        function absHilbertSamples = GetSmoothHilbertSamples(obj, hilbertSamples)
            absHilbertSamples = abs(hilbertSamples);
            for iter = 1:1:obj.numberOfSmoothIteration
                absHilbertSamples = smooth(absHilbertSamples, obj.spanForSmoothHilbertSamples, 'loess');
            end
        end

        % MomentaryPhaseFuncFromHilbert
        function momentaryPhaseFuncSeismicData = CalculateMomentaryPhaseSeismicData(obj, hilbertSeismicData)
            momentaryPhaseFuncSeismicData = copy(hilbertSeismicData);
            ConvertToMomentaryPhaseSeismicData(obj, momentaryPhaseFuncSeismicData);
        end
        function ConvertToMomentaryPhaseSeismicData(obj, hilbertSeismicData)
            for i = 1:1:hilbertSeismicData.NumberOfSeismograms
                hilbertSeismogram = hilbertSeismicData.Seismograms(i);
                ConvertToMomentaryPhaseSeismogram(obj, hilbertSeismogram);
            end
        end
        function ConvertToMomentaryPhaseSeismogram(obj, hilbertSeismogram)
            for i = 1:1:hilbertSeismogram.NumberOfSensors
                hilbertTrace = hilbertSeismogram.Traces(i);
                ConvertToMomentaryPhaseTrace(obj, hilbertTrace);
            end
        end
        function ConvertToMomentaryPhaseTrace(obj, hilbertTrace)
            hilbertSamples = hilbertTrace.Samples;
            fiFunction = GetMomentaryPhaseFuncFromHilbertSamples(obj, hilbertSamples);
            hilbertTrace.Samples = fiFunction;
        end
        function momentaryPhaseFunc = GetMomentaryPhaseFuncFromHilbertSamples(obj, hilbertSamples)
            realHilbertSamples = real(hilbertSamples);
            imagHilbertSamples = imag(hilbertSamples);
            momentaryPhaseFunc = zeros(length(realHilbertSamples),1);
            for ti = 1:1:length(realHilbertSamples)
                momentaryPhaseFunc(ti) = acos( realHilbertSamples(ti) / sqrt(realHilbertSamples(ti)^2 + imagHilbertSamples(ti)^2) );
            end
            if max(abs(momentaryPhaseFunc)) > 0
                momentaryPhaseFunc = -(momentaryPhaseFunc / max(abs(momentaryPhaseFunc)) - 0.5);
            end
        end
    end
end