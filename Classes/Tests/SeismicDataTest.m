classdef SeismicDataTest < matlab.unittest.TestCase
    properties (Access = private)
        numberOfSeismograms = 2;
        numberSamplesPerTrace = 10;
        numberSamplesPerSec = 1000;
        numberOfSensors = 3;
        sensorDistance = 50;
    end
    methods(Test)
        function ChangeSamplesInOneObjectTest(testCase)
            seismicData1 = GetSeismicData(testCase);
            seismicData2 = seismicData1;

            seismicData1 = ModifySamplesInSeismicData(testCase, seismicData1);

            testCase.verifyEqual(seismicData1, seismicData2);
        end
        function ChangeSamplesInCopyObjectTest(testCase)
            seismicData1 = GetSeismicData(testCase);
            seismicData2 = copy(seismicData1);

            seismicData1 = ModifySamplesInSeismicData(testCase, seismicData1);

            testCase.verifyNotEqual(seismicData1, seismicData2);
        end

        function ChangeSourceXInOneObjectTest(testCase)
            seismicData1 = GetSeismicData(testCase);
            seismicData2 = seismicData1;

            seismicData1 = ModifySourceXInSeismicData(testCase, seismicData1);

            testCase.verifyEqual(seismicData1, seismicData2);
        end
        function ChangeSourceXInCopyObjectTest(testCase)
            seismicData1 = GetSeismicData(testCase);
            seismicData2 = copy(seismicData1);

            seismicData1 = ModifySourceXInSeismicData(testCase, seismicData1);

            testCase.verifyNotEqual(seismicData1, seismicData2);
        end

        function ChangeSensorsXInOneObjectTest(testCase)
            seismicData1 = GetSeismicData(testCase);
            seismicData2 = seismicData1;

            seismicData1 = ModifySensorsXInSeismicData(testCase, seismicData1);

            testCase.verifyEqual(seismicData1, seismicData2);
        end
        function ChangeSensorsXInCopyObjectTest(testCase)
            seismicData1 = GetSeismicData(testCase);
            seismicData2 = copy(seismicData1);

            seismicData1 = ModifySensorsXInSeismicData(testCase, seismicData1);

            testCase.verifyNotEqual(seismicData1, seismicData2);
        end

    end

    methods(Access = private)
        function seismicData = GetSeismicData(testCase)
            seismicData = SeismicData();
            for i = 1:1:testCase.numberOfSeismograms
                seismogram = GetSeismogram(testCase);
                seismicData.Seismograms(i) = seismogram;
            end
            seismicData.NumberSamplesPerSec = testCase.numberSamplesPerSec;
            seismicData.NumberOfSamplesPerTrace = testCase.numberSamplesPerTrace;
        end
        function seismogram = GetSeismogram(testCase)
            seismogram = Seismogram();
            traces(1:testCase.numberOfSensors,1) = SeismicTrace();
            for i = 1:1:testCase.numberOfSensors
                trace = 1:1:testCase.numberSamplesPerTrace;
                seismicTrace = SeismicTrace();
                seismicTrace.Samples = trace;
                traces(i,1) = seismicTrace;
            end
            seismogram.SourceX = testCase.sensorDistance;
            seismogram.SensorsX = (1:1:testCase.numberOfSensors) * testCase.sensorDistance;
            seismogram.Traces = traces;
        end
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