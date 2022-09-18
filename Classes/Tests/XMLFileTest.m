classdef XMLFileTest < matlab.unittest.TestCase
    properties
        xmlReadFileName  = 'DataForTests\DefaultSettings_XMLReaderTest.xml'
        xmlWriteFileName = 'DataForTests\DefaultSettings_XMLWriterTest.xml'
    end
    methods(Test)
        function XMLReaderTest(testCase)
            % Arrange
            expXMLData = XMLFileTest.GetReaderExpampleXMLData();
            % Act
            xmlReader = XMLReader(testCase.xmlReadFileName);
            xmlReaderData = xmlReader.ReadApplicationConfig();
            % Assert
            testCase.verifyEqual(xmlReaderData, expXMLData);
        end
        function ApplicationConfigReaderTest(testCase)
            % Arrange
            expXMLData = XMLFileTest.GetReaderExpampleXMLData();
            expApplicationConfig = ApplicationConfigTest.GetNewInstance();
            expApplicationConfig.SetSettings(expXMLData);
            % Act
            xmlReader = XMLReader(testCase.xmlReadFileName);
            xmlReaderData = xmlReader.ReadApplicationConfig();
            readedApplicationConfig = ApplicationConfigTest.GetNewInstance();
            readedApplicationConfig.SetSettings(xmlReaderData);
            % Assert
            testCase.verifyEqual(readedApplicationConfig, expApplicationConfig);
        end
        function XMLWriterTest(testCase)
            % Arrange
            expXMLData = XMLFileTest.GetWriterExpampleXMLData();
            xmlWriter = XMLWriter(testCase.xmlWriteFileName);
            xmlWriter.WriteApplicationConfig(expXMLData);
            % Act
            xmlReader = XMLReader(testCase.xmlWriteFileName);
            xmlWriterData = xmlReader.ReadApplicationConfig();
            % Assert
            testCase.verifyEqual(xmlWriterData, expXMLData);
        end
        function ApplicationConfigWriterTest(testCase)
            % Arrange
            expXMLData = XMLFileTest.GetWriterExpampleXMLData();
            expApplicationConfig = ApplicationConfigTest.GetNewInstance();
            expApplicationConfig.SetSettings(expXMLData);
            xmlWriter = XMLWriter(testCase.xmlWriteFileName);
            xmlWriter.WriteApplicationConfig(expXMLData);
            % Act
            xmlReader = XMLReader(testCase.xmlWriteFileName);
            xmlWriterData = xmlReader.ReadApplicationConfig();
            readedApplicationConfig = ApplicationConfigTest.GetNewInstance();
            readedApplicationConfig.SetSettings(xmlWriterData);
            % Assert
            testCase.verifyEqual(readedApplicationConfig, expApplicationConfig);
        end
    end

    methods(Static)
        function expXMLData = GetReaderExpampleXMLData()
            expXMLData = XMLApplicationConfigData();
            expXMLData.BeginInputFileName = 'data\InputData\';
            expXMLData.BeginOutputFolderName = 'data\OutputData\';
            expXMLData.InputFileName = 'SG_08_tmp2.mat';
            expXMLData.OutputFolderName = 'Real1\';
            expXMLData.FileNameSuffix = '_XMLReaderTest';
            expXMLData.ModelParametersFileName = 'DefaultModelParameters.xml';
            expXMLData.SeismicDataProviderTypeName = 'MatSeismicDataProviderType';
            expXMLData.IsCalculatingPreparedInputSeismicData = '1';
        end
        function expXMLData = GetWriterExpampleXMLData()
            expXMLData = XMLApplicationConfigData();
            expXMLData.BeginInputFileName = 'data\InputData\';
            expXMLData.BeginOutputFolderName = 'data\OutputData\';
            expXMLData.InputFileName = 'SG_08_tmp2.mat';
            expXMLData.OutputFolderName = 'Real1\';
            expXMLData.FileNameSuffix = '_XMLWriterTest';
            expXMLData.ModelParametersFileName = 'DefaultModelParameters.xml';
            expXMLData.SeismicDataProviderTypeName = 'MatSeismicDataProviderType';
            expXMLData.IsCalculatingPreparedInputSeismicData = '1';
        end
    end
end

