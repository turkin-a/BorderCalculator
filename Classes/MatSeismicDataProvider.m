% Источник сейсмических данных - mat-файл
classdef MatSeismicDataProvider < ISeismicDataProvider
    properties (Access = private)
        isCalculatingPreparedInputSeismicData
        isPreparingSeismicDataComplet = false

        seismicDataFileReader SeismicDataFileReader
        seismicDataPreparer SeismicDataPreparer
        preparedSeismicData SeismicData
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
        function preparedSeismicData = GetSeismicData(obj)
            if IsCalculatingPreparedInputSeismicData(obj) == true
                initialInputSeismicData = ReadSeismicData(obj);
                preparedSeismicData = PrepareSeismicData(obj, initialInputSeismicData);
                SavePreparingSeismicData(obj, preparedSeismicData);
            else
                preparedSeismicData = LoadPreparingSeismicDataIfNeed(obj);
            end
        end
    end

    methods (Access = private)
        function result = IsCalculatingPreparedInputSeismicData(obj)
            result = false;
            if obj.isCalculatingPreparedInputSeismicData == true && obj.isPreparingSeismicDataComplet == false
                result = true;
            end
        end

        function SavePreparingSeismicData(obj, preparedSeismicData)
            fileName = GetFileNameOfPrepareSeismicData(obj);
            save(fileName, 'preparedSeismicData');
            obj.preparedSeismicData = preparedSeismicData;
            obj.isPreparingSeismicDataComplet = true;
        end
        function preparedSeismicData = LoadPreparingSeismicDataIfNeed(obj)
            if obj.isPreparingSeismicDataComplet == true
                preparedSeismicData = obj.preparedSeismicData;
            else
                fileName = GetFileNameOfPrepareSeismicData(obj);
                load(fileName, 'preparedSeismicData');
            end
        end

        function initialInputSeismicData = ReadSeismicData(obj)
            obj.seismicDataFileReader = SeismicDataFileReader(obj.fullInputFileName);
            initialInputSeismicData = obj.seismicDataFileReader.Read();
        end

        function preparedInputSeismicData = PrepareSeismicData(obj, initialInputSeismicData)
            obj.seismicDataPreparer = SeismicDataPreparer();
            obj.seismicDataPreparer.InitialSeismicData = initialInputSeismicData;
            modelParameters = ModelParameters.Instance();
            obj.seismicDataPreparer.SpanForFirstTimes = modelParameters.SpanForFirstTimes;
            obj.seismicDataPreparer.MinTraceAmpForFirstTimes = modelParameters.MinTraceAmpForFirstTimes;
            preparedInputSeismicData = obj.seismicDataPreparer.Prepare();
        end

        function fileName = GetFileNameOfPrepareSeismicData(obj)
            applicationConfig = ApplicationConfig.Instance();
            fileName = [applicationConfig.FullOutputFolderName 'PrepareSeismicData_' ...
                        applicationConfig.FileNameSuffix '.mat'];
        end
    end
end