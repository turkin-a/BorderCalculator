classdef SeismicDataProcessor < ISeismicDataProcessor
    properties (Access = private)
        seismicDataProvider ISeismicDataProvider
        directWaveCalculator IDirectWaveCalculator
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
            seismicData = obj.seismicDataProvider.GetSeismicData();
            obj.directWaveCalculator = DirectWaveCalculator(seismicData);
            directWave = obj.directWaveCalculator.GetDirectWave();
        end
    end

    methods (Access = private)
    end
end