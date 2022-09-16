classdef SeismogramTest < matlab.unittest.TestCase
    methods(Test)
        function ChangeSamplesInOneObjectTest(testCase)
            seismogram1 = SeismogramTest.GetSeismogram();
            seismogram2 = seismogram1;

            seismogram1.Traces{1}.Samples(1) = seismogram1.Traces{1}.Samples(1) + 1;

            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSamplesInCopyObjectTest(testCase)
            seismogram1 = SeismogramTest.GetSeismogram();
            seismogram2 = copy(seismogram1);

            seismogram1.Traces{1}.Samples(1) = seismogram1.Traces{1}.Samples(1) + 1;

            testCase.verifyNotEqual(seismogram1, seismogram2);
        end

        function ChangeSourceXInOneObjectTest(testCase)
            seismogram1 = SeismogramTest.GetSeismogram();
            seismogram2 = seismogram1;

            seismogram1.SourceX =  seismogram1.SourceX + 10;

            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSourceXInCopyObjectTest(testCase)
            seismogram1 = SeismogramTest.GetSeismogram();
            seismogram2 = copy(seismogram1);

            seismogram1.SourceX = seismogram1.SourceX + 1;

            testCase.verifyNotEqual(seismogram1, seismogram2);
        end

        function ChangeSensorsXInOneObjectTest(testCase)
            seismogram1 = SeismogramTest.GetSeismogram();
            seismogram2 = seismogram1;

            seismogram1.SourceX =  seismogram1.SourceX + 1;

            testCase.verifyEqual(seismogram1, seismogram2);
        end
        function ChangeSensorsXInCopyObjectTest(testCase)
            seismogram1 = SeismogramTest.GetSeismogram();
            seismogram2 = copy(seismogram1);

            seismogram1.SensorsX(1) = seismogram1.SensorsX(1) + 1;

            testCase.verifyNotEqual(seismogram1, seismogram2);
        end
    end

    methods(Static)
        function seismogram = GetSeismogram()
            numberSamplesPerTrace = 10;
            numberOfSensors = 3;
            sensorDistance = 50;
            seismogram = Seismogram();
            traces = cell(numberOfSensors, 1);
            for i = 1:1:numberOfSensors
                trace = 1:1:numberSamplesPerTrace;
                seismicTrace = SeismicTrace();
                seismicTrace.Samples = trace;
                traces{i} = seismicTrace;
            end
            seismogram.SourceX = sensorDistance;
            seismogram.SensorsX = sensorDistance:sensorDistance:sensorDistance*numberOfSensors;
            seismogram.Traces = traces;
        end
    end
end
