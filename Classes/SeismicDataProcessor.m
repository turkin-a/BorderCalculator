classdef SeismicDataProcessor < ISeismicDataProcessor
    properties (Access = private)
        seismicDataProvider ISeismicDataProvider
        directWaveCalculator IDirectWaveCalculator
        directWaveVelocities (:,1) double
        bedinIndexOfSeism double = 27
        endIndexOfSeism double = 28
        correctedSeismicData SeismicData
        hilbertSeismicData SeismicData
        analyticalSignal AnalyticalSignal

        % tmp
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
            obj.seismicDataProvider = seismicDataProviderFactory.Create();
        end
    end

    methods (Access = public)
        function obj = Calculate(obj)
            PrepareData(obj);
            CalculateAxes(obj);
        end
    end

    methods (Access = private)
        function PrepareData(obj)
            CalculateDirectWaveVelocity(obj);
            CalculateAnalyticalSignal(obj);
        end

        % Рассчет скорости прямой волны
        function CalculateDirectWaveVelocity(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'directWaveVelocities_' applicationConfig.FileNameSuffix '.mat'];
            if applicationConfig.IsCalculatingDirectWave == true
                seismicData = obj.seismicDataProvider.GetSeismicData();
                obj.directWaveCalculator = DirectWaveCalculator(seismicData);
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
                seismicData = obj.seismicDataProvider.GetSeismicData();
                analyticalSignalCalculator = AnalyticalSignalCalculator(seismicData);
                analyticalSignalCalculator.Calculate();
                analyticalSignalResult = analyticalSignalCalculator.AnalyticalSignalResult;
                save(fileName, "analyticalSignalResult");
            else
                load(fileName, "analyticalSignalResult");
            end
            obj.analyticalSignal = analyticalSignalResult;
        end
        
        function CalculateAxes(obj)
            seismicData = obj.seismicDataProvider.GetSeismicData();
            intervalsCalculator = IntervalsCalculator();
            intervalsCalculator.SurfaceVelocity = obj.surfaceVelocity;
            intervalsCalculator.NumberSamplesPerSec = seismicData.NumberSamplesPerSec;
            for indexOfSeism = obj.bedinIndexOfSeism:1:obj.endIndexOfSeism
                intervalsCalculator.Seismogram = seismicData.Seismograms(indexOfSeism);
                intervalsCalculator.DirectWaveVelocity = obj.directWaveVelocities(indexOfSeism);
                intervalsCalculator.SetParameters(obj.analyticalSignal, indexOfSeism);


                g = 1;
            end
        end


    end
end



