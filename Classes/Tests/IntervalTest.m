classdef IntervalTest < matlab.unittest.TestCase
    properties (Access = private)
        fileName = ".\DataForTests\SetOfIntervals_Seismogram27_.mat"
        setOfIntervals cell
        seismogram ISeismogram
        absHilbertSeismogram ISeismogram
        isPloting = true
    end

    methods(Test)
        function FindTypeOfInterval_01(testCase)
            % Arrange
            indexOfSensor = 52;
            indexOfInterval = 8;
            [interval, traceOfHilbert] = GetIntervalAndHilbertTrace(testCase, indexOfSensor, indexOfInterval);
            % Act
            interval.CalculateTypeByHilbertTest(traceOfHilbert);
            PlotResult(testCase, interval);
            % Assert
            testCase.verifyEqual(interval.TypeOfInterval, IntervalType.Good);
        end

        function FindTypeOfInterval_02(testCase)
            % Arrange
            indexOfSensor = 51;
            indexOfInterval = 7;
            [interval, traceOfHilbert] = GetIntervalAndHilbertTrace(testCase, indexOfSensor, indexOfInterval);
            % Act
            interval.CalculateTypeByHilbertTest(traceOfHilbert);
            PlotResult(testCase, interval);
            % Assert
            testCase.verifyEqual(interval.TypeOfInterval, IntervalType.Good);
        end

        function FindTypeOfInterval_03(testCase)
            % Arrange
            indexOfSensor = 50;
            indexOfInterval = 8;
            [interval, traceOfHilbert] = GetIntervalAndHilbertTrace(testCase, indexOfSensor, indexOfInterval);
            % Act
            interval.CalculateTypeByHilbertTest(traceOfHilbert);
            PlotResult(testCase, interval);
            % Assert
            testCase.verifyEqual(interval.TypeOfInterval, IntervalType.Good);
        end

        function FindTypeOfInterval_04(testCase)
            % Arrange
            indexOfSensor = 49;
            indexOfInterval = 7;
            [interval, traceOfHilbert] = GetIntervalAndHilbertTrace(testCase, indexOfSensor, indexOfInterval);
            % Act
            interval.CalculateTypeByHilbertTest(traceOfHilbert);
            PlotResult(testCase, interval);
            % Assert
            testCase.verifyEqual(interval.TypeOfInterval, IntervalType.Good);
        end

        function FindTypeOfInterval_10(testCase)
            % Arrange
            indexOfSensor = 47;
            indexOfInterval = 8;
            [interval, traceOfHilbert] = GetIntervalAndHilbertTrace(testCase, indexOfSensor, indexOfInterval);
            % Act
            interval.CalculateTypeByHilbertTest(traceOfHilbert);
            PlotResult(testCase, interval);
            % Assert
            testCase.verifyEqual(interval.TypeOfInterval, IntervalType.Good);
        end


    end

    methods(TestClassSetup)
        function LoadDataFromFile(testCase)
            load(testCase.fileName, "setOfIntervals", "seismogram", "absHilbertSeismogram");
            testCase.setOfIntervals = setOfIntervals;
            testCase.seismogram = seismogram;
            testCase.absHilbertSeismogram = absHilbertSeismogram;
            PlotStage(testCase);
        end
    end
    methods(Access = private)
        function PlotStage(testCase)
            if testCase.isPloting == true
                DataVisualizer.Clear();
                DataVisualizer.PlotSeismogram(testCase.seismogram, 'g-', 1);
                DataVisualizer.PlotSeismogram(testCase.absHilbertSeismogram, 'b-', 1);
                DataVisualizer.PlotSetOfIntervals(testCase.setOfIntervals, 1, 10);
            end
        end
        function PlotResult(testCase, interval)
            if testCase.isPloting == true
                DataVisualizer.PlotInterval(interval, 3, 10+5);
            end
        end

        function [interval, traceOfHilbert] = GetIntervalAndHilbertTrace(testCase, indexOfSensor, indexOfInterval)
            interval = GetInterval(testCase, indexOfSensor, indexOfInterval);
            traceOfHilbert = GetTraceOfHilbert(testCase, indexOfSensor);
        end
        function trace = GetTrace(testCase, indexOfSensor)
            trace = testCase.seismogram.Traces(indexOfSensor);
        end
        function traceOfHilbert = GetTraceOfHilbert(testCase, indexOfSensor)
            traceOfHilbert = testCase.absHilbertSeismogram.Traces(indexOfSensor);
        end
        function resultInterval = GetInterval(testCase, indexOfSensor, indexOfInterval)
            intervals = testCase.setOfIntervals{indexOfSensor};
            interval = intervals{indexOfInterval};
            resultInterval = IntervalForTest(interval);
        end

        
    end
end
