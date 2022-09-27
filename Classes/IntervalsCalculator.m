classdef IntervalsCalculator < handle
    properties (Access = private)
        seismogram ISeismogram
        directWaveVelocity double
        surfaceVelocity double
        numberSamplesPerSec double
        correctedSeismogram ISeismogram
        hilbertSeismogram ISeismogram
    end

    properties (Dependent)
        Seismogram
        DirectWaveVelocity
        SurfaceVelocity
        NumberSamplesPerSec
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

        function set.NumberSamplesPerSec(obj, numberSamplesPerSec)
            obj.numberSamplesPerSec = numberSamplesPerSec;
        end
        function numberSamplesPerSec = get.NumberSamplesPerSec(obj)
            numberSamplesPerSec = obj.numberSamplesPerSec;
        end

        function Calculate(obj)

        end
    end

    methods (Access = private)
        
    end
end