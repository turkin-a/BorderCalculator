classdef SeismicTraceTest < matlab.unittest.TestCase
    properties
        testSeismicDataBuilder TestSeismicDataBuilder = TestSeismicDataBuilder()
    end

    methods(Test)
        function ChangeOneObjectTest(testCase)
            % Arrange
            seismicTrace1 = testCase.testSeismicDataBuilder.GetSeismicTrace();
            seismicTrace2 = seismicTrace1;
            % Act
            seismicTrace1 = ModifySamplesInSeismicTrace(testCase, seismicTrace1);
            % Assert
            testCase.verifyEqual(seismicTrace1, seismicTrace2);
        end
        function ChangeCopyOfObjectsTest(testCase)
            % Arrange
            seismicTrace1 = testCase.testSeismicDataBuilder.GetSeismicTrace();
            seismicTrace2 = copy(seismicTrace1);
            % Act
            seismicTrace1 = ModifySamplesInSeismicTrace(testCase, seismicTrace1);
            % Assert
            testCase.verifyNotEqual(seismicTrace1, seismicTrace2);
        end
    end

    methods(Access = private)
        function seismicTrace = ModifySamplesInSeismicTrace(testCase, seismicTrace)
            seismicTrace.Samples(1) = seismicTrace.Samples(1) + 1;
        end
    end
end
