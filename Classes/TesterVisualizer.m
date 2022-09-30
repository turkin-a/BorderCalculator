classdef TesterVisualizer < ISingleton
    properties (Access = private)
        seismicData SeismicData
        directWaveVelocities (:,1) double
        analyticalSignal AnalyticalSignal
        momentaryPhaseSeismicData SeismicData
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
            Li = abs(momentaryPhaseSeismogram.SourceX - momentaryPhaseSeismogram.SensorsX);
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
            DataVisualizer.SetTitle(num2str(indexOfSeismogram));

            DataVisualizer.PlotSeismogram(obj.seismicData.Seismograms(indexOfSeismogram), 'g-', 1);
            DataVisualizer.PlotSeismogram(obj.analyticalSignal.CorrectedSeismicData.Seismograms(indexOfSeismogram), 'g--', 1);
            DataVisualizer.PlotSeismogram(obj.analyticalSignal.CorrectedAbsHilbertSeismicData.Seismograms(indexOfSeismogram), 'b-', 1);
            DataVisualizer.PlotSeismogram(obj.momentaryPhaseSeismicData.Seismograms(indexOfSeismogram), 'm-', 1);
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