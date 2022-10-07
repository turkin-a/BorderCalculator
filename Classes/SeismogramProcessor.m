classdef SeismogramProcessor < handle
    properties (Access = private)
        intervalsCalculator IntervalsCalculator
        pointCalculator PointCalculator
        parametersOfAxesCalculator ParametersOfPermissibleAxesCalculator

        seismogram ISeismogram
        correctedSeismogram ISeismogram
        hilbertSeismogram ISeismogram
        correctedAbsHilbertSeismogram ISeismogram
        momentaryPhaseSeismogram ISeismogram
        directWaveVelocity double
        numberSamplesPerSec double

        surfaceVelocity double
        setOfIntervals (:,1) cell
        setOfPoints1 (:,1) cell
        setOfPoints2 (:,1) cell

        isCalculateIntervals = 0
        isCalculatePoints = 0
        isCalculatingParametersOfPermissibleAxes = 0
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
            CalculateParametersOfPermissibleAxes(obj);
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
%                 obj.intervalsCalculator.NumberSamplesPerSec = obj.numberSamplesPerSec;
                obj.intervalsCalculator.DirectWaveVelocity = obj.directWaveVelocity;
                obj.intervalsCalculator.Calculate();
                setOfIntervalsResult = obj.intervalsCalculator.SetOfIntervals;
                save(fileName, "setOfIntervalsResult");
            else
                load(fileName, "setOfIntervalsResult");
            end
            obj.setOfIntervals = setOfIntervalsResult;
            TesterVisualizer.SetIntervals(setOfIntervalsResult);
        end

        function CalculatePoints(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'PointCalculatorResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isCalculatePoints == true
                obj.pointCalculator.MomentaryPhaseSeismogram = obj.momentaryPhaseSeismogram;
                obj.pointCalculator.AbsHilbertSeismogram = obj.correctedAbsHilbertSeismogram;
                obj.pointCalculator.SetOfIntervals = obj.setOfIntervals;
                obj.pointCalculator.SurfaceVelocity = obj.surfaceVelocity;
                obj.pointCalculator.DirectWaveVelocity = obj.directWaveVelocity;
                obj.pointCalculator.Calculate();
                setOfPointsResult1 = obj.pointCalculator.SetOfPoints1;
                setOfPointsResult2 = obj.pointCalculator.SetOfPoints2;
                save(fileName, "setOfPointsResult1", "setOfPointsResult2");
            else
                load(fileName, "setOfPointsResult1", "setOfPointsResult2");
            end
            obj.setOfPoints1 = setOfPointsResult1;
            obj.setOfPoints2 = setOfPointsResult2;
            TesterVisualizer.SetPoints1(setOfPointsResult1);
            TesterVisualizer.SetPoints2(setOfPointsResult2);
            
        end

        function CalculateParametersOfPermissibleAxes(obj)
%             TesterVisualizer.PlotTestedData();


            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'ParametersOfPermissibleAxesResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isCalculatingParametersOfPermissibleAxes == true
                obj.parametersOfAxesCalculator = ParametersOfPermissibleAxesCalculator(obj.correctedAbsHilbertSeismogram, obj.directWaveVelocity);
                obj.parametersOfAxesCalculator.SetOfPoints1 = obj.setOfPoints1;
                obj.parametersOfAxesCalculator.SetOfPoints2 = obj.setOfPoints2;
                obj.parametersOfAxesCalculator.Calculate();
                setOfPermissibleAxesParams1 = obj.parametersOfAxesCalculator.SetOfPermissibleAxesParams1;
                setOfPermissibleAxesParams2 = obj.parametersOfAxesCalculator.SetOfPermissibleAxesParams2;
                save(fileName, "setOfPermissibleAxesParams1", "setOfPermissibleAxesParams2");
            else
                load(fileName, "setOfPermissibleAxesParams1", "setOfPermissibleAxesParams2");
            end

            TesterVisualizer.PlotTestedData();
        end


    end
end



