classdef XMLReader < handle
    properties (Access = private, Constant)
    end    
    properties (Access = private)
        xmlFullFileName = 'DefaultSettings.xml';
    end
    
    properties (Dependent)
    end
    
    methods
        function obj = XMLReader(xmlFullFileName)
            obj.xmlFullFileName = xmlFullFileName;
            import matlab.io.xml.dom.*
        end        
    end
   
    methods (Access = public)
        function xmlData = ReadXML(obj)
            parser = matlab.io.xml.dom.Parser();
            doc = parseFile(parser, obj.xmlFullFileName);
            
            xmlData = XMLData();
            docRootNode = doc.getDocumentElement();
            xmlData.DocumentVersionOfConfig = docRootNode.getAttribute('version');
            xmlData.InputFileName = doc.getElementsByTagName('inputFileName').getTextContent;
            xmlData.BeginInputFileName = doc.getElementsByTagName('beginInputFileName').getTextContent;
            xmlData.BeginOutputFolderName = doc.getElementsByTagName('beginOutputFolderName').getTextContent;
            xmlData.OutputFolderName = doc.getElementsByTagName('outputFolderName').getTextContent;
            xmlData.FileNameSuffix = doc.getElementsByTagName('fileNameSuffix').getTextContent;
        end
    end
    methods (Access = private)
    end
end