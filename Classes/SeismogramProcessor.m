classdef SeismogramProcessor < handle
    properties (Access = private)
        intervalsCalculator IntervalsCalculator
        pointCalculator PointCalculator

        seismogram ISeismogram
        correctedSeismogram ISeismogram
        hilbertSeismogram ISeismogram
        correctedAbsHilbertSeismogram ISeismogram
        momentaryPhaseSeismogram ISeismogram
        directWaveVelocity double
        numberSamplesPerSec double

        surfaceVelocity double
        setOfIntervals (:,1) cell
        setOfPoints (:,1) cell

        isCalculateIntervals = 0
        isCalculatePoints = 1
    end
    properties (Access = public, Dependent)
        Seismogram
        DirectWaveVelocity
    end

    methods
        function obj = SeismogramProcessor(surfaceVelocity, numberSamplesPerSec)
            obj.intervalsCalculator = IntervalsCalculator();
            obj.pointCalculator = PointCalculator();
            obj.surfaceVelocity = surfaceVelocity;
            obj.numberSamplesPerSec = numberSamplesPerSec;
        end

        function SetParameters(obj, analyticalSignal, indexOfSeism)
            obj.correctedSeismogram = analyticalSignal.CorrectedSeismicData.Seismograms(indexOfSeism);
            obj.hilbertSeismogram = analyticalSignal.HilbertSeismicData.Seismograms(indexOfSeism);
            obj.correctedAbsHilbertSeismogram = analyticalSignal.CorrectedAbsHilbertSeismicData.Seismograms(indexOfSeism);
            obj.momentaryPhaseSeismogram = analyticalSignal.MomentaryPhaseSeismicData.Seismograms(indexOfSeism);
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
            CalculatePoints(obj);
        end
    end

    methods (Access = private)
        function CalculateIntervals(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'IntervalsCalculatorResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isCalculateIntervals == true
                obj.intervalsCalculator.Seismogram = obj.seismogram;
                obj.intervalsCalculator.CorrectedAbsHilbertSeismogram = obj.correctedAbsHilbertSeismogram;
                obj.intervalsCalculator.SurfaceVelocity = obj.surfaceVelocity;
                obj.intervalsCalculator.NumberSamplesPerSec = obj.numberSamplesPerSec;
                obj.intervalsCalculator.DirectWaveVelocity = obj.directWaveVelocity;
                obj.intervalsCalculator.Calculate();
                setOfIntervalsResult = obj.intervalsCalculator.SetOfIntervals;
                save(fileName, "setOfIntervalsResult");
            else
                load(fileName, "setOfIntervalsResult");
            end
            obj.setOfIntervals = setOfIntervalsResult;
        end

        function CalculatePoints(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'PointCalculatorResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isCalculatePoints == true
                obj.pointCalculator.MomentaryPhaseSeismogram = obj.momentaryPhaseSeismogram;
                obj.pointCalculator.SetOfIntervals = obj.setOfIntervals;
                obj.pointCalculator.SurfaceVelocity = obj.surfaceVelocity;
                obj.pointCalculator.DirectWaveVelocity = obj.directWaveVelocity;
                obj.pointCalculator.NumberSamplesPerSec = obj.numberSamplesPerSec;
                obj.pointCalculator.Calculate();
                setOfPointsResult = obj.pointCalculator.SetOfPoints;
                save(fileName, "setOfPointsResult");
            else
                load(fileName, "setOfPointsResult");
            end
            obj.setOfPoints = setOfPointsResult;
        end


    end
end



