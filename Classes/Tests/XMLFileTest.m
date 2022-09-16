classdef XMLFileTest < matlab.unittest.TestCase
    methods(Test)
        function XMLReaderTest(testCase)
            expXMLData = XMLFileTest.GetReaderExpampleXMLData();

            xmlFileName = 'DataForTests\DefaultSettings_XMLReaderTest.xml';
            xmlReader = XMLReader(xmlFileName);
            xmlReaderData = xmlReader.ReadApplicationConfig();

            testCase.verifyEqual(xmlReaderData, expXMLData);
        end
        function ApplicationConfigReaderTest(testCase)
            expXMLData = XMLFileTest.GetReaderExpampleXMLData();
            expApplicationConfig = ApplicationConfigTest.GetNewInstance();
            expApplicationConfig.SetSettings(expXMLData);

            xmlFileName = 'DataForTests\DefaultSettings_XMLReaderTest.xml';
            xmlReader = XMLReader(xmlFileName);
            xmlReaderData = xmlReader.ReadApplicationConfig();
            readedApplicationConfig = ApplicationConfigTest.GetNewInstance();
            readedApplicationConfig.SetSettings(xmlReaderData);

            testCase.verifyEqual(readedApplicationConfig, expApplicationConfig);
        end
        function XMLWriterTest(testCase)
            expXMLData = XMLFileTest.GetWriterExpampleXMLData();

            xmlFileName = 'DataForTests\DefaultSettings_XMLWriterTest.xml';
            xmlWriter = XMLWriter(xmlFileName);
            xmlWriter.WriteApplicationConfig(expXMLData);

            xmlReader = XMLReader(xmlFileName);
            xmlWriterData = xmlReader.ReadApplicationConfig();
            testCase.verifyEqual(xmlWriterData, expXMLData);
        end
        function ApplicationConfigWriterTest(testCase)
            expXMLData = XMLFileTest.GetWriterExpampleXMLData();
            expApplicationConfig = ApplicationConfigTest.GetNewInstance();
            expApplicationConfig.SetSettings(expXMLData);

            xmlFileName = 'DataForTests\DefaultSettings_XMLWriterTest.xml';
            xmlWriter = XMLWriter(xmlFileName);
            xmlWriter.WriteApplicationConfig(expXMLData);

            xmlReader = XMLReader(xmlFileName);
            xmlWriterData = xmlReader.ReadApplicationConfig();
            readedApplicationConfig = ApplicationConfigTest.GetNewInstance();
            readedApplicationConfig.SetSettings(xmlWriterData);

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

