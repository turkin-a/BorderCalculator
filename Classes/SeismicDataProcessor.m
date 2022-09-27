classdef SeismicDataProcessor < ISeismicDataProcessor
    properties (Access = private)
        seismicDataProvider ISeismicDataProvider
        directWaveCalculator IDirectWaveCalculator
        directWaveVelocities (:,1) double
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
            CalculateDirectWaveVelocity(obj);

        end
    end

    methods (Access = private)
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

        % Рассчет корелляции
        function obj = CalculateCorrelation(obj)
            if obj.modelParameters.IsCalculateCorrelation
                correlationCalculator = CorrelationCalculator(obj.preparedInputSeismicData, obj.modelParameters, obj.directWaveCalculator);
                correlationCalculator.StartCalculate();
                obj.preparedInputSeismicData = correlationCalculator.InputSeismicData();
                
                obj.pointTimesOfMiddleFreqForAllSeis = correlationCalculator.PointTimesOfMiddleFreqForAllSeis;
                obj.pointTimesOfMinFreqForAllSeis = correlationCalculator.PointTimesOfMinFreqForAllSeis;
                obj.pointTimesOfMaxFreqForAllSeis = correlationCalculator.PointTimesOfMaxFreqForAllSeis;
                SaveCorrelationData(obj);
            end
            LoadCorrelationData(obj);
        end
        
    end
end