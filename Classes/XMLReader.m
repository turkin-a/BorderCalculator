classdef XMLReader < handle
    properties (Access = private)
        xmlFullFileName (1,:) char = []
    end

    methods
        function obj = XMLReader(xmlFullFileName)
            obj.xmlFullFileName = xmlFullFileName;
            import matlab.io.xml.dom.*
        end
    end

    methods (Access = public)
        function xmlData = ReadApplicationConfig(obj)
            parser = matlab.io.xml.dom.Parser();
            doc = parseFile(parser, obj.xmlFullFileName);

            xmlData = XMLApplicationConfigData();
            docRootNode = doc.getDocumentElement();
            xmlData = ReadFieldNames(obj, docRootNode, xmlData);
        end
        function xmlData = ReadModelParameters(obj)
            parser = matlab.io.xml.dom.Parser();
            doc = parseFile(parser, obj.xmlFullFileName);

            xmlData = XMLModelParametersData();
            docRootNode = doc.getDocumentElement();
            xmlData = ReadFieldNames(obj, docRootNode, xmlData);
        end
    end

    methods (Access = private)
        function xmlData = ReadFieldNames(obj, docRootNode, xmlData)
            documentVersion = ReadDocumentVersion(obj, docRootNode, xmlData);
            xmlData.SetDocumentVersion(documentVersion);
            fieldNames = fieldnames(xmlData);
            for i = 1:1:length(fieldNames)
                fieldName = fieldNames{i};
                fieldValue = docRootNode.getElementsByTagName(fieldName).getTextContent;
                xmlData.(fieldName) = fieldValue;
            end
        end
        function documentVersion = ReadDocumentVersion(obj, docRootNode, xmlData)
            documentVersion = docRootNode.getAttribute('version');
            if IsDocumentVersionGood(obj, documentVersion, xmlData) == false
                msgID = 'XMLReader:OldFileVersion';
                msgtext = ['Old version of file. This version of this file "' obj.xmlFullFileName ...
                           '" is not supported. Minimum version is ' num2str(documentVersion)];
                ME = MException(msgID,msgtext);
                throw(ME);
            end
        end
        function result = IsDocumentVersionGood(obj, documentVersion, xmlData)
            result = true;
            if documentVersion < str2double(xmlData.GetMinDocumentVersion)
                result = false;
            end
        end
    end
end
