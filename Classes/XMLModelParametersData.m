classdef XMLModelParametersData
    properties (Access = private, Constant)
        minDocumentVersion (1,:) char = '0.1'
    end

    properties (Access = private)
        documentVersion (1,:) char = []
    end

    properties (Access = public)
        SpanForFirstTimes (1,:) char = []
        MinTraceAmpForFirstTimes (1,:) char = []
    end

    methods (Access = public)
        function obj = XMLModelParametersData()
            obj.documentVersion = obj.minDocumentVersion;
        end

        function documentVersion = GetDocumentVersionOfConfig(obj)
            documentVersion = obj.documentVersion;
        end

        function obj = SetDocumentVersion(obj, documentVersion)
            obj.documentVersion = documentVersion;
        end

        function minDocumentVersion = GetMinDocumentVersion(obj)
            minDocumentVersion = obj.minDocumentVersion;
        end
    end
end