classdef SeismicTraceTest < matlab.unittest.TestCase
    properties
        numberSamplesPerTrace = 10;
    end
    methods(Test)
        function ChangeOneObjectTest(testCase)
            seismicTrace1 = GetSeismicTrace(testCase);
            seismicTrace2 = seismicTrace1;

            seismicTrace1 = ModifySamplesInSeismicTrace(testCase, seismicTrace1);

            testCase.verifyEqual(seismicTrace1, seismicTrace2);
        end
        function ChangeCopyOfObjectsTest(testCase)
            seismicTrace1 = GetSeismicTrace(testCase);
            seismicTrace2 = copy(seismicTrace1);

            seismicTrace1 = ModifySamplesInSeismicTrace(testCase, seismicTrace1);

            testCase.verifyNotEqual(seismicTrace1, seismicTrace2);
        end
    end

    methods(Access = private)
        function seismicTrace = GetSeismicTrace(testCase)
            seismicTrace = SeismicTrace();
            samples = 1:1:testCase.numberSamplesPerTrace;
            seismicTrace.Samples = samples;
        end
        function seismicTrace = ModifySamplesInSeismicTrace(testCase, seismicTrace)
            seismicTrace.Samples(1) = seismicTrace.Samples(1) + 1;
        end
    end
end
