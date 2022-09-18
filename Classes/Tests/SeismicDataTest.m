classdef SeismicDataTest < matlab.unittest.TestCase
    properties (Access = private)
        testSeismicDataBuilder TestSeismicDataBuilder = TestSeismicDataBuilder()
    end

    methods(Test)
        function ChangeSamplesInOneObjectTest(testCase)
            % Arrange
            seismicData1 = testCase.testSeismicDataBuilder.GetSeismicData();
            seismicData2 = seismicData1;
            % Act
            seismicData1 = ModifySamplesInSeismicData(testCase, seismicData1);
            % Assert
            testCase.verifyEqual(seismicData1, seismicData2);
        end
        function ChangeSamplesInCopyObjectTest(testCase)
            % Arrange
            seismicData1 = testCase.testSeismicDataBuilder.GetSeismicData();
            seismicData2 = copy(seismicData1);
            % Act
            seismicData1 = ModifySamplesInSeismicData(testCase, seismicData1);
            % Assert
            testCase.verifyNotEqual(seismicData1, seismicData2);
        end

        function ChangeSourceXInOneObjectTest(testCase)
            % Arrange
            seismicData1 = testCase.testSeismicDataBuilder.GetSeismicData();
            seismicData2 = seismicData1;
            % Act
            seismicData1 = ModifySourceXInSeismicData(testCase, seismicData1);
            % Assert
            testCase.verifyEqual(seismicData1, seismicData2);
        end
        function ChangeSourceXInCopyObjectTest(testCase)
            % Arrange
            seismicData1 = testCase.testSeismicDataBuilder.GetSeismicData();
            seismicData2 = copy(seismicData1);
            % Act
            seismicData1 = ModifySourceXInSeismicData(testCase, seismicData1);
            % Assert
            testCase.verifyNotEqual(seismicData1, seismicData2);
        end

        function ChangeSensorsXInOneObjectTest(testCase)
            % Arrange
            seismicData1 = testCase.testSeismicDataBuilder.GetSeismicData();
            seismicData2 = seismicData1;
            % Act
            seismicData1 = ModifySensorsXInSeismicData(testCase, seismicData1);
            % Assert
            testCase.verifyEqual(seismicData1, seismicData2);
        end
        function ChangeSensorsXInCopyObjectTest(testCase)
            % Arrange
            seismicData1 = testCase.testSeismicDataBuilder.GetSeismicData();
            seismicData2 = copy(seismicData1);
            % Act
            seismicData1 = ModifySensorsXInSeismicData(testCase, seismicData1);
            % Assert
            testCase.verifyNotEqual(seismicData1, seismicData2);
        end
    end

    methods(Access = private)
        function seismicData = ModifySamplesInSeismicData(testCase, seismicData)
            seismicData.Seismograms(1,1).Traces(1,1).Samples(1) = seismicData.Seismograms(1,1).Traces(1,1).Samples(1) + 1;
        end

        function seismicData = ModifySourceXInSeismicData(testCase, seismicData)
            seismicData.Seismograms(1,1).SensorsX = seismicData.Seismograms(1,1).SensorsX + 1;
        end

        function seismicData = ModifySensorsXInSeismicData(testCase, seismicData)
            seismicData.Seismograms(1,1).SensorsX(1) = seismicData.Seismograms(1,1).SensorsX(1) + 1;
        end
    end
end