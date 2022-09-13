classdef XMLWriter < handle
    properties (Access = private, Constant)
    end    
    properties (Access = private)
        xmlFullFileName = 'DefaultSettings.xml';
        document = []
    end
    
    properties (Dependent)
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
        function obj = Write(obj, xmlData)
            docRootNode = getDocumentElement(obj.document);
            docRootNode.setAttribute('version', xmlData.DocumentVersionOfConfig);
            
            appendElement(obj, 'inputFileName', xmlData.InputFileName);
            appendElement(obj, 'beginInputFileName', xmlData.BeginInputFileName);
            appendElement(obj, 'beginOutputFolderName', xmlData.BeginOutputFolderName);
            appendElement(obj, 'outputFolderName', xmlData.OutputFolderName);
            appendElement(obj, 'fileNameSuffix', xmlData.FileNameSuffix);

            writer = matlab.io.xml.dom.DOMWriter;
            writer.Configuration.FormatPrettyPrint = 1;
            writeToFile(writer, obj.document, obj.xmlFullFileName);
        end
    end
    methods (Access = private)
        function obj = appendElement(obj, elementName, elementValue)
            docRootNode = getDocumentElement(obj.document);
            newElement = createElement(obj.document, elementName);
            appendChild(newElement, createTextNode(obj.document, elementValue));
            appendChild(docRootNode, newElement);
        end
    end
end