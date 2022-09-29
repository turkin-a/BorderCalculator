classdef SeismicDataProcessor < ISeismicDataProcessor
    properties (Access = private)
%         seismicDataProvider ISeismicDataProvider
        directWaveCalculator IDirectWaveCalculator
        seismicData SeismicData
        directWaveVelocities (:,1) double
        bedinIndexOfSeism double = 27
        endIndexOfSeism double = 28
%         correctedSeismicData SeismicData
%         hilbertSeismicData SeismicData
        analyticalSignal AnalyticalSignal
        seismogramProcessor SeismogramProcessor

%         % tmp
        surfaceVelocity = 300
        isCalculatingAnalyticalSignal = 0
    end
    properties (Access = public, Dependent)
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
            for indexOfSeism = obj.bedinIndexOfSeism:1:obj.endIndexOfSeism
                obj.seismogramProcessor.Seismogram = obj.seismicData.Seismograms(indexOfSeism);
                obj.seismogramProcessor.DirectWaveVelocity = obj.directWaveVelocities(indexOfSeism);
                obj.seismogramProcessor.SetParameters(obj.analyticalSignal, indexOfSeism);
                obj.seismogramProcessor.Calculate();

                g = 1;
            end
        end


    end
end



