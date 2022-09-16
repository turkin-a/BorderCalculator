classdef SeismogramTest < matlab.unittest.TestCase
    properties
        numberSamplesPerTrace = 10;
        numberOfSensors = 3;
        sensorDistance = 50;
    end
    methods(Test)
        function ChangeSamplesInOneObjectTest(testCase)
            seismogram1 = GetSeismogram(testCase);
            seismogram2 = seismogram1;

            seismogram1 = ModifySamplesInSeismogram(testCase, seismogram1);

            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSamplesInCopyObjectTest(testCase)
            seismogram1 = GetSeismogram(testCase);
            seismogram2 = copy(seismogram1);

            seismogram1 = ModifySamplesInSeismogram(testCase, seismogram1);

            testCase.verifyNotEqual(seismogram1, seismogram2);
        end

        function ChangeSourceXInOneObjectTest(testCase)
            seismogram1 = GetSeismogram(testCase);
            seismogram2 = seismogram1;

            seismogram1 = ModifySourceXInSeismogram(testCase, seismogram1);

            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSourceXInCopyObjectTest(testCase)
            seismogram1 = GetSeismogram(testCase);
            seismogram2 = copy(seismogram1);

            seismogram1 = ModifySourceXInSeismogram(testCase, seismogram1);

            testCase.verifyNotEqual(seismogram1, seismogram2);
        end

        function ChangeSensorsXInOneObjectTest(testCase)
            seismogram1 = GetSeismogram(testCase);
            seismogram2 = seismogram1;

            seismogram1 = ModifySensorsXInSeismogram(testCase, seismogram1);

            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSensorsXInCopyObjectTest(testCase)
            seismogram1 = GetSeismogram(testCase);
            seismogram2 = copy(seismogram1);

            seismogram1 = ModifySensorsXInSeismogram(testCase, seismogram1);

            testCase.verifyNotEqual(seismogram1, seismogram2);
        end
    end

    methods(Access = private)
        function seismogram = GetSeismogram(testCase)
            seismogram = Seismogram();
            traces(1:testCase.numberOfSensors,1) = SeismicTrace();
            for i = 1:1:testCase.numberOfSensors
                trace = 1:1:testCase.numberSamplesPerTrace;
                seismicTrace = SeismicTrace();
                seismicTrace.Samples = trace;
                traces(i) = seismicTrace;
            end
            seismogram.SourceX = testCase.sensorDistance;
            seismogram.SensorsX = (1:1:testCase.numberOfSensors) * testCase.sensorDistance;
            seismogram.Traces = traces;
        end
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
