classdef SeismicTraceTest < matlab.unittest.TestCase
    properties (Access = private)
        testSeismicDataBuilder TestSeismicDataBuilder = TestSeismicDataBuilder()
        timeOfMax = 150
        timesOfMax = [151; 301]
        minTraceAmplitude = 0.03;
    end

    methods(Test)
        function ChangeOneObjectTest(testCase)
            % Arrange
            seismicTrace1 = testCase.testSeismicDataBuilder.GetIncreasedAmplitudeSeismicTrace();
            seismicTrace2 = seismicTrace1;
            % Act
            seismicTrace1 = ModifySamplesInSeismicTrace(testCase, seismicTrace1);
            % Assert
            testCase.verifyEqual(seismicTrace1, seismicTrace2);
        end
        function ChangeCopyOfObjectsTest(testCase)
            % Arrange
            seismicTrace1 = testCase.testSeismicDataBuilder.GetIncreasedAmplitudeSeismicTrace();
            seismicTrace2 = copy(seismicTrace1);
            % Act
            seismicTrace1 = ModifySamplesInSeismicTrace(testCase, seismicTrace1);
            % Assert
            testCase.verifyNotEqual(seismicTrace1, seismicTrace2);
        end

        function CalculateFirstTimeWithOneAmpMax_Span1Test(testCase)
            % Arrange
            trace1 = testCase.testSeismicDataBuilder.GetSeismicTraceWithAxis(testCase.timeOfMax);
            span = 1;
            % Act
            firstTime = trace1.CalculateAndGetFirstTime(span, testCase.minTraceAmplitude);
            % Assert
            testCase.verifyEqual(testCase.timeOfMax, firstTime);
        end
        function CalculateFirstTimeWithOneAmpMax_Span5Test(testCase)
            % Arrange
            trace1 = testCase.testSeismicDataBuilder.GetSeismicTraceWithAxis(testCase.timeOfMax);
            span = 5;
            % Act
            firstTime = trace1.CalculateAndGetFirstTime(span, testCase.minTraceAmplitude);
            % Assert
            testCase.verifyEqual(testCase.timeOfMax, firstTime);
        end

        function GetTimeOfMaxAmplitudesTest(testCase)
            % Arrange
            trace1 = testCase.testSeismicDataBuilder.GetSeismicTraceWithImpulses(testCase.timeOfMax);
            firstTime = 1;
            % Act
            [maxTimes, ~] = trace1.GetTimesOfMaxAndMinAmplitudes(firstTime);
            % Assert
            testCase.verifyEqual(testCase.timeOfMax, maxTimes);
        end

        function GetTimesOfMaxAmplitudesTest(testCase)
            % Arrange
            trace1 = testCase.testSeismicDataBuilder.GetSeismicTraceWithImpulses(testCase.timesOfMax);
            firstTime = 1;
            % Act
            [maxTimes, ~] = trace1.GetTimesOfMaxAndMinAmplitudes(firstTime);
            % Assert
            testCase.verifyEqual(testCase.timesOfMax, maxTimes);
        end
    end

    methods(Access = private)
        function seismicTrace = ModifySamplesInSeismicTrace(testCase, seismicTrace)
            seismicTrace.Samples(1) = seismicTrace.Samples(1) + 1;
        end
    end
end
