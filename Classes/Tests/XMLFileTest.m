classdef XMLFileTest < matlab.unittest.TestCase
    methods(Test)
        function XMLReaderTest(testCase)
            expXMLData = XMLApplicationConfigData();
%             documentVersion = expXMLData.GetMinDocumentVersion();
%             expXMLData.SetDocumentVersion(documentVersion);
            expXMLData.BeginInputFileName = 'data\InputData\';
            expXMLData.BeginOutputFolderName = 'data\OutputData\';
            expXMLData.InputFileName = 'SG_08_tmp2.mat';
            expXMLData.OutputFolderName = 'Real1\';
            expXMLData.FileNameSuffix = '_XMLReaderTest';
            expXMLData.ModelParametersFileName = 'DefaultModelParameters.xml';
            
            xmlFileName = 'DataForTests\DefaultSettings_XMLReaderTest.xml';
            xmlReader = XMLReader(xmlFileName);
            xmlWriterData = xmlReader.ReadApplicationConfig();
            testCase.verifyEqual(xmlWriterData, expXMLData);
        end
        function XMLWriterTest(testCase)
            expXMLData = XMLApplicationConfigData();
            expXMLData.BeginInputFileName = 'data\InputData\';
            expXMLData.BeginOutputFolderName = 'data\OutputData\';
            expXMLData.InputFileName = 'SG_08_tmp2.mat';
            expXMLData.OutputFolderName = 'Real1\';
            expXMLData.FileNameSuffix = '_XMLWriterTest';
            expXMLData.ModelParametersFileName = 'DefaultModelParameters.xml';
            
            xmlFileName = 'DataForTests\DefaultSettings_XMLWriterTest.xml';
            xmlWriter = XMLWriter(xmlFileName);
            xmlWriter.WriteApplicationConfig(expXMLData);
            
            xmlReader = XMLReader(xmlFileName);
            xmlWriterData = xmlReader.ReadApplicationConfig();
            testCase.verifyEqual(xmlWriterData, expXMLData);
        end
    end
end