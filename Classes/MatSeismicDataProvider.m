% Источник сейсмических данных - mat-файл
classdef MatSeismicDataProvider < ISeismicDataProvider
    properties (Access = private)
        isCalculatingPreparedInputSeismicData
        fullInputFileName
    end
    properties (Access = public, Dependent)
    end

    methods
        function obj = MatSeismicDataProvider(fullInputFileName, isCalculatingPreparedInputSeismicData)
            obj.fullInputFileName = fullInputFileName;
            obj.isCalculatingPreparedInputSeismicData = isCalculatingPreparedInputSeismicData;
        end
    end

    methods (Access = public)
        function seismicData = GetSeismicData(obj)
            seismicData = [];
            if obj.isCalculatingPreparedInputSeismicData == true
                ReadSeismicData(obj);
            end
        end
    end

    methods (Access = private)
        function seismicData = ReadSeismicData(obj)
            seismicData = [];
            seismicDataFileReader = SeismicDataFileReader(obj.fullInputFileName);
            initialInputSeismicData = seismicDataFileReader.Read();
        end
    end
end