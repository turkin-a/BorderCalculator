% Источник сейсмических данных - mat-файл
classdef MatSeismicDataProvider < ISeismicDataProvider
    properties (Access = private)
        isCalculatingPreparedInputSeismicData
        seismicDataFileReader SeismicDataFileReader
        seismicDataPreparer SeismicDataPreparer
        fullInputFileName (1,:) char = []
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
                initialInputSeismicData = ReadSeismicData(obj);
                preparedInputSeismicData = PrepareSeismicData(obj, initialInputSeismicData);
            end
        end
    end

    methods (Access = private)
        function initialInputSeismicData = ReadSeismicData(obj)
            obj.seismicDataFileReader = SeismicDataFileReader(obj.fullInputFileName);
            initialInputSeismicData = obj.seismicDataFileReader.Read();
        end
        function preparedInputSeismicData = PrepareSeismicData(obj, initialInputSeismicData)
            obj.seismicDataPreparer = SeismicDataPreparer();
            obj.seismicDataPreparer.InitialSeismicData = initialInputSeismicData;
            obj.seismicDataPreparer.SpanForFirstTimes
            obj.seismicDataPreparer.MinTraceAmpForFirstTimes
            preparedInputSeismicData = obj.seismicDataPreparer.Prepare();
        end
    end
end