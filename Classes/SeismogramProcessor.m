classdef SeismogramProcessor < handle
    properties (Access = private)
        intervalsCalculator IntervalsCalculator

        seismogram ISeismogram
        correctedSeismogram ISeismogram
        hilbertSeismogram ISeismogram
        correctedAbsHilbertSeismogram ISeismogram
        momentaryPhaseFuncSeismogram ISeismogram
        directWaveVelocity double
        numberSamplesPerSec double


        surfaceVelocity double
    end
    properties (Access = public, Dependent)
        Seismogram
        DirectWaveVelocity
    end

    methods
        function obj = SeismogramProcessor(surfaceVelocity, numberSamplesPerSec)
            obj.intervalsCalculator = IntervalsCalculator();
            obj.surfaceVelocity = surfaceVelocity;
            obj.numberSamplesPerSec = numberSamplesPerSec;
        end

        function SetParameters(obj, analyticalSignal, indexOfSeism)
            obj.correctedSeismogram = analyticalSignal.CorrectedSeismicData.Seismograms(indexOfSeism);
            obj.hilbertSeismogram = analyticalSignal.HilbertSeismicData.Seismograms(indexOfSeism);
            obj.correctedAbsHilbertSeismogram = analyticalSignal.CorrectedAbsHilbertSeismicData.Seismograms(indexOfSeism);
            obj.momentaryPhaseFuncSeismogram = analyticalSignal.MomentaryPhaseFuncSeismicData.Seismograms(indexOfSeism);
        end

        function set.Seismogram(obj, seismogram)
            obj.seismogram = seismogram;
        end
        function seismogram = get.Seismogram(obj)
            seismogram = obj.seismogram;
        end

        function set.DirectWaveVelocity(obj, directWaveVelocity)
            obj.directWaveVelocity = directWaveVelocity;
        end
        function directWaveVelocity = get.DirectWaveVelocity(obj)
            directWaveVelocity = obj.directWaveVelocity;
        end
    end

    methods (Access = public)
        function obj = Calculate(obj)
            CalculateIntervals(obj);
        end
    end

    methods (Access = private)
        function CalculateIntervals(obj)
            obj.intervalsCalculator.Seismogram = obj.seismogram;
            obj.intervalsCalculator.CorrectedAbsHilbertSeismogram = obj.correctedAbsHilbertSeismogram;
            obj.intervalsCalculator.SurfaceVelocity = obj.surfaceVelocity;
            obj.intervalsCalculator.NumberSamplesPerSec = obj.numberSamplesPerSec;
            obj.intervalsCalculator.DirectWaveVelocity = obj.directWaveVelocity;
            obj.intervalsCalculator.Calculate();
            setOfIntervals = obj.intervalsCalculator.SetOfIntervals();
            g = 1;
        end


    end
end



