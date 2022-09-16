classdef SeismicTraceTest < matlab.unittest.TestCase
    methods(Test)
        function ChangeOneObjectTest(testCase)
            seismicTrace1 = SeismicTraceTest.GetSeismicTrace();
            seismicTrace2 = seismicTrace1;

            seismicTrace1.Samples(1) = seismicTrace1.Samples(1) + 1;

            testCase.verifyEqual(seismicTrace1, seismicTrace2);
        end
        function ChangeCopyOfObjectsTest(testCase)
            seismicTrace1 = SeismicTraceTest.GetSeismicTrace();
            seismicTrace2 = copy(seismicTrace1);

            seismicTrace1.Samples(1) = seismicTrace1.Samples(1) + 1;

            testCase.verifyNotEqual(seismicTrace1, seismicTrace2);
        end
    end

    methods(Static)
        function seismicTrace = GetSeismicTrace()
            seismicTrace = SeismicTrace();
            sz = 10;
            samples = 1:1:sz;
            seismicTrace.Samples = samples;
        end
    end
end
