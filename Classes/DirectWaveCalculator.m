classdef DirectWaveCalculator < IDirectWaveCalculator
    properties (Access = private)
        seismicData SeismicData
        velocities (:,1) double = []
        maxDistanceForVelocityCalculation (1,1) double = 1000
    end

    properties (Dependent)

    end

    methods
        function obj = DirectWaveCalculator(seismicData)
            obj.seismicData = seismicData;
        end

        function directWave = GetDirectWave(obj)
            directWave = [];
            CalculateDirectWaveForSeismicData(obj);
        end
    end

    methods (Access = private)
        function CalculateDirectWaveForSeismicData(obj)
            for indexOfSeis = 1:1:obj.seismicData.NumberOfSeismograms
                seismogram = obj.seismicData.Seismograms(indexOfSeis);
                [velocity] = GetDirectWaveForSeismogram(obj, seismogram);
                obj.velocities(indexOfSeis,1) = velocity;
            end
        end

        function velocity = GetDirectWaveForSeismogram(obj, seismogram)
            velocity = [];
            distanceBetwenTwoSensors = seismogram.GetDistanceBetwenTwoSensors();
            CountPointV1 = round(obj.maxDistanceForVelocityCalculation / distanceBetwenTwoSensors);

        end
    end
end