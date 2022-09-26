classdef SeismicDataProcessor < ISeismicDataProcessor
    properties (Access = private)
        seismicDataProvider ISeismicDataProvider
        directWaveCalculator IDirectWaveCalculator
        directWaveVelocity (:,1) double
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
            seismicData = obj.seismicDataProvider.GetSeismicData();
            obj.directWaveCalculator = DirectWaveCalculator(seismicData);
            obj.directWaveVelocity = obj.directWaveCalculator.GetDirectWaveVelocity();
        end

        
    end
end