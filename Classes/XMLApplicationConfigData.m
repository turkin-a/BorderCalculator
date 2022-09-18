classdef XMLApplicationConfigData
    properties (Access = private, Constant)
        minDocumentVersion (1,:) char = '1.2'
    end

    properties (Access = private)
        documentVersion (1,:) char = []
    end

    properties (Access = public)
        InputFileName (1,:) char = []
        OutputFolderName (1,:) char = []
        BeginInputFileName (1,:) char = []
        BeginOutputFolderName (1,:) char = []
        FileNameSuffix (1,:) char = []
        ModelParametersFileName (1,:) char = []
        SeismicDataProviderTypeName (1,:) char = []
        IsCalculatingPreparedInputSeismicData (1,:) char = []
    end

    methods (Access = public)
        function obj = XMLApplicationConfigData()
            obj.documentVersion = obj.minDocumentVersion;
        end

        function documentVersionOfConfig = GetDocumentVersion(obj)
            documentVersionOfConfig = obj.documentVersion;
        end

        function obj = SetDocumentVersion(obj, documentVersion)
            obj.documentVersion = documentVersion;
        end

        function fullInputFileName = GetFullInputFileName(obj)
            fullInputFileName = [obj.BeginInputFileName obj.InputFileName];
        end

        function fullOutputFolderName = GetFullOutputFolderName(obj)
            fullOutputFolderName = [obj.BeginOutputFolderName obj.OutputFolderName];
        end

        function minDocumentVersion = GetMinDocumentVersion(obj)
            minDocumentVersion = obj.minDocumentVersion;
        end
    end
end