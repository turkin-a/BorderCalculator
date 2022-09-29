classdef TestSeismicDataBuilder < handle
    properties (Access = private)
        numberOfSeismograms = 2
        numberSamplesPerTrace = 500
        numberSamplesPerSec = 1000
        numberOfSensors = 11
        sensorDistance = 50

        sechParam = 60;
        amplitude = 10
        velocity1 = 1500
        h = 200
    end

    properties (Dependent)
        Velocity1
        NumberOfSeismograms
        NumberOfSensors
    end

    methods
        function v1 = get.Velocity1(obj)
            v1 = obj.velocity1;
        end
        function set.Velocity1(obj, v1)
            obj.velocity1 = v1;
        end

        function numberOfSeismograms = get.NumberOfSeismograms(obj)
            numberOfSeismograms = obj.numberOfSeismograms;
        end
        function set.NumberOfSeismograms(obj, numberOfSeismograms)
            obj.numberOfSeismograms = numberOfSeismograms;
        end

        function numberOfSensors = get.NumberOfSensors(obj)
            numberOfSensors = obj.numberOfSensors;
        end
        function set.NumberOfSensors(obj, numberOfSensors)
            obj.numberOfSensors = numberOfSensors;
        end
    end

    methods (Access = public)
        function directWaveTimes = GetDirectWaveTimes(obj)
            dt = 1 / obj.numberSamplesPerSec;
            SourceX = GetSourceX(obj);
            SensorsX = GetSensorsX(obj);
            Li = abs(SensorsX - SourceX);
            directWaveTimes = round( (Li / obj.velocity1) / dt);
        end
        function axisTimes = GetAxisTimes(obj)
            dt = 1 / obj.numberSamplesPerSec;
            SourceX = GetSourceX(obj);
            SensorsX = GetSensorsX(obj);
            Li = abs(SensorsX - SourceX);
            axisTimes = round(sqrt( Li.^2 + 4 * obj.h^2) / (obj.velocity1) / dt);
        end

        function seismicData = GetSeismicDataWithAxis(obj)
            seismicData = SeismicData();
            for i = 1:1:obj.numberOfSeismograms
                seismogram = GetSeismogramWithAxis(obj);
                seismicData.Seismograms(i) = seismogram;
            end
            seismicData.NumberSamplesPerSec = obj.numberSamplesPerSec;
            seismicData.NumberOfSamplesPerTrace = obj.numberSamplesPerTrace;
        end

        function seismogram = GetSeismogramWithAxis(obj)
            seismogram = Seismogram();
            traces(1:obj.numberOfSensors,1) = SeismicTrace();
            directWaveTimes = GetDirectWaveTimes(obj);
            axisTimes = GetAxisTimes(obj);
            for indexOfSensor = 1:1:obj.numberOfSensors
                axisTime = axisTimes(indexOfSensor);
                directWaveTime = directWaveTimes(indexOfSensor);
                timesOfMax = [directWaveTime axisTime];
                seismicTrace = GetSeismicTraceWithAxis(obj, timesOfMax);
                traces(indexOfSensor,1) = seismicTrace;
            end
            seismogram.SourceX = GetSourceX(obj);
            seismogram.SensorsX = GetSensorsX(obj);
            seismogram.Traces = traces;
        end


        function seismicTrace = GetSeismicTraceWithAxis(obj, timesOfMax)
            seismicTrace = SeismicTrace();
            samples = GetSamplesWithAmplitudes(obj, timesOfMax);
            seismicTrace.Samples = samples;
        end

        function seismicTrace = GetIncreasedAmplitudeSeismicTrace(obj)
            seismicTrace = SeismicTrace();
            samples = 1:1:obj.numberSamplesPerTrace;
            seismicTrace.Samples = samples;
        end

        function seismicTrace = GetSeismicTraceWithImpulses(obj, timesOfImpulses)
            seismicTrace = SeismicTrace();
            samples = GetSamplesWithImpulses(obj, timesOfImpulses);
            seismicTrace.Samples = samples;
        end

        function seismicDataForMatFile = GetSeismicDataForMatFile(obj)
            seismicDataForMatFile.SampPerTrace = obj.numberSamplesPerTrace;
            seismicDataForMatFile.discret = obj.numberSamplesPerSec;
            for i = 1:1:obj.numberOfSeismograms
                seismicDataForMatFile.Seis{1,i} = GetSeismogramForMatFile(obj);
                seismicDataForMatFile.mDetonX(1,i) = GetSourceX(obj);
                seismicDataForMatFile.mXd{1,i} = GetSensorsX(obj);
                seismicDataForMatFile.mZd{1,i} = GetSensorsZ(obj);
            end
        end

    end

    methods (Access = private)
        function samples = GetSamplesWithAmplitudes(obj, timesOfMax)
            samples = zeros(1,obj.numberSamplesPerTrace);
            for i = 1:1:length(timesOfMax)
                timeOfMax = timesOfMax(i);
                if timeOfMax > 0 && timeOfMax < obj.numberSamplesPerTrace
                    samples(timeOfMax) = obj.amplitude;
                end
            end
        end

        function samples = GetSamplesWithImpulses(obj, timesOfImpulses)
            samples = zeros(1,obj.numberSamplesPerTrace);
            for i = 1:1:length(timesOfImpulses)
                timesOfImpulse = timesOfImpulses(i);
                samples = AddImpulseToSamples(obj, samples, timesOfImpulse);
            end
        end
        function samples = AddImpulseToSamples(obj, samples, timesOfImpulse)
            dt = 1 / obj.numberSamplesPerSec;
            for t = 1:1:obj.numberSamplesPerTrace
                tau = t - timesOfImpulse;
                samples(t) = samples(t) + obj.amplitude * sech(obj.sechParam * tau * dt);
            end
        end

        function seismogramForMatFile = GetSeismogramForMatFile(obj)
            seismogramForMatFile = zeros(obj.numberOfSensors,obj.numberSamplesPerTrace);
            directWaveTimes = GetDirectWaveTimes(obj);
            axisTimes = GetAxisTimes(obj);
            for indexOfTrace = 1:1:obj.numberOfSensors
                axisTime = axisTimes(indexOfTrace);
                directWaveTime = directWaveTimes(indexOfTrace);
                timesOfMax = [directWaveTime axisTime];
                samples = GetSamplesWithAmplitudes(obj, timesOfMax);
                seismogramForMatFile(indexOfTrace,:) = samples;
            end
        end

        function sourcesX = GetSourcesX(obj)
            sourcesX = zeros(1,obj.numberOfSensors) + GetSourceX(obj);
        end

        function sourceX = GetSourceX(obj)
            indexofCenterSensor = round(obj.numberOfSensors / 2);
            sourceX = obj.sensorDistance * indexofCenterSensor;
        end

        function sensorsX = GetSensorsX(obj)
            sensorsX = (1:1:obj.numberOfSensors) * obj.sensorDistance;
        end

        function sensorsZ = GetSensorsZ(obj)
            sensorsZ = (1:1:obj.numberOfSensors) * 0;
        end
    end
end