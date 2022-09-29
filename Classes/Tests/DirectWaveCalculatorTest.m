classdef DirectWaveCalculatorTest < matlab.unittest.TestCase
    properties
        testSeismicDataBuilder TestSeismicDataBuilder = TestSeismicDataBuilder()
        numberOfSeismograms = 1
        numberOfSensors = 31
        velocity1 = 1500
        span = 5
        minTraceAmplitude = 0.03
    end

    methods(Test)
        function CalculateDirectWaveTest(testCase)
            % Arrange
            testCase.testSeismicDataBuilder.Velocity1 = testCase.velocity1;
            testCase.testSeismicDataBuilder.NumberOfSeismograms = testCase.numberOfSeismograms;
            testCase.testSeismicDataBuilder.NumberOfSensors = testCase.numberOfSensors;
            seismicData = testCase.testSeismicDataBuilder.GetSeismicDataWithAxis();
            seismicData.CalculateFirstTimes(testCase.span, testCase.minTraceAmplitude);
            directWaveCalculator = DirectWaveCalculator(seismicData);
            % Act
            calculatedVelocity = round(directWaveCalculator.GetDirectWaveVelocity());
            % Assert
            testCase.verifyEqual(calculatedVelocity, testCase.velocity1);
        end
    end

    methods(Access = public)

    end
end