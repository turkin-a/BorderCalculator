classdef TesterVisualizer < ISingleton
    properties (Access = private)
        seismicData SeismicData
        directWaveVelocities (:,1) double
        analyticalSignal AnalyticalSignal
        momentaryPhaseSeismicData SeismicData

        setOfIntervals cell
        setOfMaxTimes cell
        setOfMinTimes cell
        setOfPoints1 cell
        setOfPoints2 cell
        indexOfSeismogram
    end

    methods (Access = private)
        function obj = TesterVisualizer()
        end

        function CorrectMomentaryPhaseSeismicData(obj)
            for indexOfSeism = 1:1:obj.momentaryPhaseSeismicData.NumberOfSeismograms
                momentaryPhaseSeismogram = obj.momentaryPhaseSeismicData.Seismograms(indexOfSeism);
                velocity = obj.directWaveVelocities(indexOfSeism);
                CorrectMomentaryPhaseSeismogram(obj, momentaryPhaseSeismogram, velocity);
            end
        end

        function CorrectMomentaryPhaseSeismogram(obj, momentaryPhaseSeismogram, velocity)
            Li = momentaryPhaseSeismogram.GetDistancesFromSource();
            directWaveTimes = round( Li*1000 / velocity);
            for indexOfSensor = 1:1:momentaryPhaseSeismogram.NumberOfSensors
                momentaryPhaseTraces = momentaryPhaseSeismogram.Traces(indexOfSensor);
                directWaveTime = directWaveTimes(indexOfSensor);
                CorrectMomentaryPhaseTraces(obj, momentaryPhaseTraces, directWaveTime)
            end
        end

        function CorrectMomentaryPhaseTraces(obj, momentaryPhaseTraces, directWaveTime)
            if directWaveTime > 0
                if directWaveTime > momentaryPhaseTraces.NumberOfSamplesPerTrace
                    directWaveTime = momentaryPhaseTraces.NumberOfSamplesPerTrace;
                end
                momentaryPhaseTraces.Samples(1:directWaveTime) = 0;
            end
        end

    end

    methods (Access = public, Static)
        function SetData(seismicData, analyticalSignal, directWaveVelocities)
            obj = TesterVisualizer.Instance();
            obj.seismicData = seismicData;
            obj.directWaveVelocities = directWaveVelocities;
            obj.analyticalSignal = analyticalSignal;
            obj.momentaryPhaseSeismicData = copy(obj.analyticalSignal.MomentaryPhaseSeismicData);
            CorrectMomentaryPhaseSeismicData(obj);
        end

        function PlotStage(indexOfSeismogram)
            obj = TesterVisualizer.Instance();
            obj.indexOfSeismogram = indexOfSeismogram;
            DataVisualizer.SetNumberOfFigure(1);
            DataVisualizer.Clear();
            DataVisualizer.SetTitle(num2str(obj.indexOfSeismogram));

%             DataVisualizer.PlotSeismogram(obj.seismicData.Seismograms(indexOfSeismogram), 'g-', 1);
            DataVisualizer.PlotSeismogram(obj.analyticalSignal.CorrectedSeismicData.Seismograms(indexOfSeismogram), 'g-', 1);
            DataVisualizer.PlotSeismogram(obj.analyticalSignal.CorrectedAbsHilbertSeismicData.Seismograms(indexOfSeismogram), 'b-', 1);
%             DataVisualizer.PlotSeismogram(obj.momentaryPhaseSeismicData.Seismograms(indexOfSeismogram), 'm-', 1);
        end
        function PlotTestedData()
            obj = TesterVisualizer.Instance();
            TesterVisualizer.PlotStage(obj.indexOfSeismogram);

%             DataVisualizer.PlotSetOfTimes(obj.setOfMaxTimes, 'r+', 7);
%             DataVisualizer.PlotSetOfTimes(obj.setOfMinTimes, 'b+', 7);

            absHilbertSeismogram = obj.analyticalSignal.CorrectedAbsHilbertSeismicData.Seismograms(obj.indexOfSeismogram);
            DataVisualizer.PlotSetOfIntervals(obj.setOfIntervals, 3, 8);
            DataVisualizer.PlotHilbertInSetOfIntervals(obj.setOfIntervals, absHilbertSeismogram, 3, 8);

            TesterVisualizer.PlotSetOfPoints();
            
        end

        function PlotSetOfPoints()
            obj = TesterVisualizer.Instance();
            markerSize = 6;
            lineWidth = 1;
            DataVisualizer.PlotSetOfPoints(obj.setOfPoints1, markerSize, lineWidth);
            DataVisualizer.PlotSetOfPoints(obj.setOfPoints2, markerSize, lineWidth);
        end

        function SetIntervals(setOfIntervals)
            obj = TesterVisualizer.Instance();
            obj.setOfIntervals = setOfIntervals;
        end
        function SetMaxAndMinHilbertTimes(setOfMaxTimes, setOfMinTimes)
            obj = TesterVisualizer.Instance();
            obj.setOfMaxTimes = setOfMaxTimes;
            obj.setOfMinTimes = setOfMinTimes;
        end
        function SetPoints1(setOfPoints1)
            obj = TesterVisualizer.Instance();
            obj.setOfPoints1 = setOfPoints1;
        end
        function SetPoints2(setOfPoints2)
            obj = TesterVisualizer.Instance();
            obj.setOfPoints2 = setOfPoints2;
        end


        function obj = Instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = TesterVisualizer();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end

end