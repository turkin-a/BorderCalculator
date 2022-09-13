classdef XMLFileTest < matlab.unittest.TestCase
    methods(Test)
        function XMLReaderTest(testCase)
            expXMLData = XMLData();
            expXMLData.DocumentVersionOfConfig = '1.0a';
            expXMLData.BeginInputFileName = 'data\InputData\';
            expXMLData.BeginOutputFolderName = 'data\OutputData\';
            expXMLData.InputFileName = 'SG_08_tmp2.mat';
            expXMLData.OutputFolderName = 'Real3\';
            expXMLData.FileNameSuffix = '_XMLReaderTest';
            
            xmlFileName = 'DataForTests\DefaultSettings_XMLReaderTest.xml';
            xmlReader = XMLReader(xmlFileName);
            xmlWriterData = xmlReader.ReadXML();
            testCase.verifyEqual(xmlWriterData, expXMLData);
        end
        function XMLWriterTest(testCase)
            expXMLData = XMLData();
            expXMLData.BeginInputFileName = 'data\InputData\';
            expXMLData.BeginOutputFolderName = 'data\OutputData\';
            expXMLData.InputFileName = 'SG_08_tmp2.mat';
            expXMLData.OutputFolderName = 'Real3\';
            expXMLData.FileNameSuffix = '_XMLWriterTest';
            
            xmlFileName = 'DataForTests\DefaultSettings_XMLWriterTest.xml';
            xmlWriter = XMLWriter(xmlFileName);
            xmlWriter.Write(expXMLData);
            
            xmlReader = XMLReader(xmlFileName);
            xmlWriterData = xmlReader.ReadXML();
            testCase.verifyEqual(xmlWriterData, expXMLData);
        end
    end
end