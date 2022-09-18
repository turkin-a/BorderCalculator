classdef XMLWriter < handle
    properties (Access = private)
        xmlFullFileName (1,:) char = []
        document = []
    end

    methods
        function obj = XMLWriter(xmlFullFileName)
            [~, fileName, ext] = fileparts(xmlFullFileName);
            xmlFileName = [fileName ext];
            obj.xmlFullFileName = xmlFullFileName;
            import matlab.io.xml.dom.*
            obj.document = Document(xmlFileName);
        end
    end

    methods (Access = public)
        function obj = WriteApplicationConfig(obj, xmlData)
            docRootNode = getDocumentElement(obj.document);
            docRootNode.setAttribute('version', xmlData.GetDocumentVersion());
            appendElements(obj, xmlData);
            writer = matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint = 1;
            writeToFile(writer, obj.document, obj.xmlFullFileName);
        end
    end

    methods (Access = private)
        function obj = appendElements(obj, xmlData)
            fieldNames = fieldnames(xmlData);
            for i = 1:1:length(fieldNames)
                fieldName = fieldNames{i};
                fieldValue = xmlData.(fieldName);
                appendElement(obj, fieldName, fieldValue);
            end
        end

        function obj = appendElement(obj, elementName, elementValue)
            docRootNode = getDocumentElement(obj.document);
            newElement = createElement(obj.document, elementName);
            appendChild(newElement, createTextNode(obj.document, elementValue));
            appendChild(docRootNode, newElement);
        end
    end
end