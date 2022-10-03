classdef SeismicDataProcessor < ISeismicDataProcessor
    properties (Access = private)
        directWaveCalculator IDirectWaveCalculator
        seismicData SeismicData
        directWaveVelocities (:,1) double
        analyticalSignal AnalyticalSignal
        seismogramProcessor SeismogramProcessor

        % tmp
        isCalculatingAnalyticalSignal = 0
    end
    properties (Access = private, Constant)
        bedinIndexOfSeism double = 27
        endIndexOfSeism double = 28
        surfaceVelocity = 300
    end

    methods
        function obj = SeismicDataProcessor()
            applicationConfig = ApplicationConfig.Instance();
            typeOfSeismicDataProvider = applicationConfig.SeismicDataProviderType;
            seismicDataProviderFactory = SeismicDataProviderFactory(typeOfSeismicDataProvider);
            seismicDataProvider = seismicDataProviderFactory.Create();

            obj.seismicData = seismicDataProvider.GetSeismicData();
            obj.seismogramProcessor = SeismogramProcessor(obj.surfaceVelocity, obj.seismicData.NumberSamplesPerSec);
        end
    end

    methods (Access = public)
        function obj = Calculate(obj)
            CalculateAdditionalData(obj);
            CalculateAxes(obj);
        end
    end

    methods (Access = private)
        function CalculateAdditionalData(obj)
            CalculateDirectWaveVelocity(obj);
            CalculateAnalyticalSignal(obj);

            % TesterVisualizer
            TesterVisualizer.SetData(obj.seismicData, obj.analyticalSignal, obj.directWaveVelocities);
        end

        % Рассчет скорости прямой волны
        function CalculateDirectWaveVelocity(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'directWaveVelocities_' applicationConfig.FileNameSuffix '.mat'];
            if applicationConfig.IsCalculatingDirectWave == true
                obj.directWaveCalculator = DirectWaveCalculator(obj.seismicData);
                velocities = obj.directWaveCalculator.GetDirectWaveVelocity();
                save(fileName, "velocities");
            else
                load(fileName, "velocities");
            end
            obj.directWaveVelocities = velocities;
        end
        
        function CalculateAnalyticalSignal(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'AnalyticalSignalResult_' applicationConfig.FileNameSuffix '.mat'];
            if obj.isCalculatingAnalyticalSignal == true
                analyticalSignalCalculator = AnalyticalSignalCalculator(obj.seismicData);
                analyticalSignalCalculator.Calculate();
                analyticalSignalResult = analyticalSignalCalculator.AnalyticalSignalResult;
                save(fileName, "analyticalSignalResult");
            else
                load(fileName, "analyticalSignalResult");
            end
            obj.analyticalSignal = analyticalSignalResult;
        end
        
        function CalculateAxes(obj)
            for indexOfSeismogram = obj.bedinIndexOfSeism:1:obj.endIndexOfSeism
                % TesterVisualizer
                TesterVisualizer.PlotStage(indexOfSeismogram);

                obj.seismogramProcessor.Seismogram = obj.seismicData.Seismograms(indexOfSeismogram);
                obj.seismogramProcessor.DirectWaveVelocity = obj.directWaveVelocities(indexOfSeismogram);
                obj.seismogramProcessor.SetParameters(obj.analyticalSignal, indexOfSeismogram);
                obj.seismogramProcessor.Calculate();

                g = 1;
            end
        end


    end
end



