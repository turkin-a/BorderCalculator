classdef SeismicDataProviderFactory < handle
    properties (Access = private)
        typeOfSeismicDataProvider (1,1) SeismicDataProviderTypes
    end
    properties (Access = public, Dependent)
    end

    methods
        function obj = SeismicDataProviderFactory(typeOfSeismicDataProvider)
            obj.typeOfSeismicDataProvider = typeOfSeismicDataProvider;
        end

        function seismicDataProvider = Create(obj)
            if obj.typeOfSeismicDataProvider == SeismicDataProviderTypes.MatSeismicDataProviderType
                applicationConfig = ApplicationConfig.Instance();
                seismicDataProvider = MatSeismicDataProvider(applicationConfig.FullInputFileName, ...
                                                             applicationConfig.IsCalculatingPreparedInputSeismicData);
            else
                errID = 'SeismicDataProviderFactory:Create:WrongTypeOfSeismicDataProvider';
                msgtext = 'Wrong value of TypeOfSeismicDataProvider';
                baseException = MException(errID,msgtext);
                throw(baseException);
            end
        end
    end

    methods (Access = private)
    end
end