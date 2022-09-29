classdef SeismogramTest < matlab.unittest.TestCase
    properties
        testSeismicDataBuilder TestSeismicDataBuilder = TestSeismicDataBuilder()
        minTraceAmplitude = 0.03;
    end

    methods(Test)
        function ChangeSamplesInOneObjectTest(testCase)
            % Arrange
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            seismogram2 = seismogram1;
            % Act
            seismogram1 = ModifySamplesInSeismogram(testCase, seismogram1);
            % Assert
            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSamplesInCopyObjectTest(testCase)
            % Arrange
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            seismogram2 = copy(seismogram1);
            % Act
            seismogram1 = ModifySamplesInSeismogram(testCase, seismogram1);
            % Assert
            testCase.verifyNotEqual(seismogram1, seismogram2);
        end

        function ChangeSourceXInOneObjectTest(testCase)
            % Arrange
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            seismogram2 = seismogram1;
            % Act
            seismogram1 = ModifySourceXInSeismogram(testCase, seismogram1);
            % Assert
            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSourceXInCopyObjectTest(testCase)
            % Arrange
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            seismogram2 = copy(seismogram1);
            % Act
            seismogram1 = ModifySourceXInSeismogram(testCase, seismogram1);
            % Assert
            testCase.verifyNotEqual(seismogram1, seismogram2);
        end

        function ChangeSensorsXInOneObjectTest(testCase)
            % Arrange
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            seismogram2 = seismogram1;
            % Act
            seismogram1 = ModifySensorsXInSeismogram(testCase, seismogram1);
            % Assert
            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSensorsXInCopyObjectTest(testCase)
            % Arrange
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            seismogram2 = copy(seismogram1);
            % Act
            seismogram1 = ModifySensorsXInSeismogram(testCase, seismogram1);
            % Assert
            testCase.verifyNotEqual(seismogram1, seismogram2);
        end

        function CalculateFirstTimesWithOneAmpMax_Span1Test(testCase)
            % Arrange
            directWaveTimes1 = testCase.testSeismicDataBuilder.GetDirectWaveTimes();
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            span = 1;
            
            % Act
            seismogram1.CalculateFirstTimes(span, testCase.minTraceAmplitude);
            firstTimes = seismogram1.FirstTimes;
            % Assert
            testCase.verifyEqual(directWaveTimes1, firstTimes);
        end
        function CalculateFirstTimesWithOneAmpMax_Span5Test(testCase)
            % Arrange
            directWaveTimes1 = testCase.testSeismicDataBuilder.GetDirectWaveTimes();
            seismogram1 = testCase.testSeismicDataBuilder.GetSeismogramWithAxis();
            span = 5;
            % Act
            seismogram1.CalculateFirstTimes(span, testCase.minTraceAmplitude);
            firstTimes = seismogram1.FirstTimes;
            % Assert
            testCase.verifyEqual(directWaveTimes1, firstTimes);
        end
    end

    methods(Access = private)
        function seismogram = ModifySamplesInSeismogram(testCase, seismogram)
            seismogram.Traces(1,1).Samples(1) = seismogram.Traces(1,1).Samples(1) + 1;
        end

        function seismogram = ModifySourceXInSeismogram(testCase, seismogram)
            seismogram.SourceX = seismogram.SourceX + 1;
        end

        function seismogram = ModifySensorsXInSeismogram(testCase, seismogram)
            seismogram.SensorsX(1,1) = seismogram.SensorsX(1,1) + 1;
        end
    end
end
