classdef SeismicDataFileReaderTest < matlab.unittest.TestCase
    properties
        testSeismicDataBuilder TestSeismicDataBuilder = TestSeismicDataBuilder()
        xmlReadFileName = 'DataForTests\ReadSeismicDataFromMatFileTest.mat'
    end

    methods(Test)
        function ReadSeismicDataFromMatFileTest(testCase)
            % Arrange
            expSeismicData = testCase.testSeismicDataBuilder.GetSeismicDataWithAxis();
            PrepareSeismicDataInMatFile(testCase);
            % Act
            seismicDataFileReader = SeismicDataFileReader(testCase.xmlReadFileName);
            actSeismicData = seismicDataFileReader.Read();
            % Assert
            testCase.verifyEqual(actSeismicData, expSeismicData);
        end
    end

    methods(Access = public)
        function PrepareSeismicDataInMatFile(testCase)
            seismicDataForMatFile = testCase.testSeismicDataBuilder.GetSeismicDataForMatFile();
            SampPerTrace = seismicDataForMatFile.SampPerTrace;
            Seis = seismicDataForMatFile.Seis;
            discret = seismicDataForMatFile.discret;
            mDetonX = seismicDataForMatFile.mDetonX;
            mXd = seismicDataForMatFile.mXd;
            mZd = seismicDataForMatFile.mZd;
            save(testCase.xmlReadFileName, ...
                'SampPerTrace', ...
                'Seis', ...
                'discret', ...
                'mDetonX', ...
                'mXd', ...
                'mZd');
        end
    end
end