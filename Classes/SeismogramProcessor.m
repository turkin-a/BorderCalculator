classdef SeismogramProcessor < handle
    properties (Access = private)
        intervalsCalculator IntervalsCalculator
        pointCalculator PointCalculator
        parametersOfAxesCalculator ParametersOfPermissibleAxesCalculator
        pairsOfPointCalculator PairsOfPointCalculator
        pairsOfPointPreparer PairsOfPointPreparer
        wayCalculator WayCalculator

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
        setOfPermissibleAxesParams1
        setOfPermissibleAxesParams2
        initialSetOfPairsOfPoints1
        initialSetOfPairsOfPoints2
        preparedSetOfPairsOfPoints1
        preparedSetOfPairsOfPoints2
        ways1
        ways2

        isCalculateIntervals = 0
        isCalculatePoints = 0
        isCalculatingParametersOfPermissibleAxes = 0
        isCalculatingPairsOfPoints = 0
        isPreparingPairsOfPoint = 0
        isCalculatingWays = 1
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
            CalculatePairsOfPoints(obj);
            PreparePairsOfPoints(obj);
            CalculateWays(obj);
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
                setOfAxesParamsResult1 = obj.parametersOfAxesCalculator.SetOfPermissibleAxesParams1;
                setOfAxesParamsResult2 = obj.parametersOfAxesCalculator.SetOfPermissibleAxesParams2;
                save(fileName, "setOfAxesParamsResult1", "setOfAxesParamsResult2");
            else
                load(fileName, "setOfAxesParamsResult1", "setOfAxesParamsResult2");
            end

            obj.setOfPermissibleAxesParams1 = setOfAxesParamsResult1;
            obj.setOfPermissibleAxesParams2 = setOfAxesParamsResult2;
%             TesterVisualizer.PlotTestedData();
        end

        function CalculatePairsOfPoints(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'PairsOfPointsResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isCalculatingPairsOfPoints == true
                obj.pairsOfPointCalculator = PairsOfPointCalculator(obj.correctedAbsHilbertSeismogram);
                obj.pairsOfPointCalculator.SetOfPoints1 = obj.setOfPoints1;
                obj.pairsOfPointCalculator.SetOfPoints2 = obj.setOfPoints2;
                obj.pairsOfPointCalculator.SetOfPermissibleAxesParams1 = obj.setOfPermissibleAxesParams1;
                obj.pairsOfPointCalculator.SetOfPermissibleAxesParams2 = obj.setOfPermissibleAxesParams2;
                obj.pairsOfPointCalculator.Calculate();
                setOfPairsOfPointsResult1 = obj.pairsOfPointCalculator.SetOfPairsOfPoints1;
                setOfPairsOfPointsResult2 = obj.pairsOfPointCalculator.SetOfPairsOfPoints2;
                save(fileName, "setOfPairsOfPointsResult1", "setOfPairsOfPointsResult2");
            else
                load(fileName, "setOfPairsOfPointsResult1", "setOfPairsOfPointsResult2");
            end

            obj.initialSetOfPairsOfPoints1 = setOfPairsOfPointsResult1;
            obj.initialSetOfPairsOfPoints2 = setOfPairsOfPointsResult2;
            TesterVisualizer.SetInitialPairsOfPoints1(setOfPairsOfPointsResult1);
            TesterVisualizer.SetInitialPairsOfPoints2(setOfPairsOfPointsResult2);

%             TesterVisualizer.PlotTestedData();
        end

        function PreparePairsOfPoints(obj)            
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'PreparedPairsOfPointsResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isPreparingPairsOfPoint == true
                obj.pairsOfPointPreparer = PairsOfPointPreparer(obj.correctedAbsHilbertSeismogram);
                obj.pairsOfPointPreparer.Calculate(obj.initialSetOfPairsOfPoints1, obj.initialSetOfPairsOfPoints2);
                setOfPairsOfPointsResult1 = obj.pairsOfPointPreparer.SetOfPairsOfPoints1;
                setOfPairsOfPointsResult2 = obj.pairsOfPointPreparer.SetOfPairsOfPoints2;
                save(fileName, "setOfPairsOfPointsResult1", "setOfPairsOfPointsResult2");
            else
                load(fileName, "setOfPairsOfPointsResult1", "setOfPairsOfPointsResult2");
            end
            obj.preparedSetOfPairsOfPoints1 = setOfPairsOfPointsResult1;
            obj.preparedSetOfPairsOfPoints2 = setOfPairsOfPointsResult2;
            TesterVisualizer.PreparedPairsOfPoints1(setOfPairsOfPointsResult1);
            TesterVisualizer.PreparedPairsOfPoints2(setOfPairsOfPointsResult2);
           
%             TesterVisualizer.PlotTestedData();
        end



        function CalculateWays(obj)
            TesterVisualizer.PlotTestedData();
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'WaysResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isCalculatingWays == true
                obj.wayCalculator = WayCalculator(obj.correctedAbsHilbertSeismogram);
                obj.wayCalculator.InitialSetOfPairs1 = obj.initialSetOfPairsOfPoints1;
                obj.wayCalculator.InitialSetOfPairs2 = obj.initialSetOfPairsOfPoints2;
                obj.wayCalculator.PreparedSetOfPairs1 = obj.preparedSetOfPairsOfPoints1;
                obj.wayCalculator.PreparedSetOfPairs2 = obj.preparedSetOfPairsOfPoints2;
                obj.wayCalculator.Calculate();
                waysResult1 = obj.pairsOfPointCalculator.Ways1;
                waysResult2 = obj.pairsOfPointCalculator.Ways2;
                save(fileName, "waysResult1", "WaysResult2");
            else
                load(fileName, "WaysResult1", "WaysResult2");
            end

            obj.ways1 = waysResult1;
            obj.ways2 = waysResult2;
%             TesterVisualizer.SetPairsOfPoints1(setOfPairsOfPointsResult1);
%             TesterVisualizer.SetPairsOfPoints2(setOfPairsOfPointsResult2);
% 
%             TesterVisualizer.PlotTestedData();
        end


    end
end



