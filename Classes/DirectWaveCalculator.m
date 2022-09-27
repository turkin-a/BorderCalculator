classdef DirectWaveCalculator < IDirectWaveCalculator
    properties (Access = private)
        seismicData SeismicData
        velocities (:,1) double = []
        maxDistanceForVelocityCalculation (1,1) double = 1000
        maxDiffTime (1,1) double = 10
        timeDiapasonForRemoveOutburst (1,1) double = 100
    end

    methods
        function obj = DirectWaveCalculator(seismicData)
            obj.seismicData = seismicData;
        end

        function directWaveVelocity = GetDirectWaveVelocity(obj)
            CalculateDirectWaveVelocityForSeismicData(obj);
            directWaveVelocity = obj.velocities;
        end
    end

    methods (Access = private)
        function CalculateDirectWaveVelocityForSeismicData(obj)
            for indexOfSeis = 1:1:obj.seismicData.NumberOfSeismograms
                seismogram = obj.seismicData.Seismograms(indexOfSeis);
                [velocity] = GetDirectWaveVelocityForSeismogram(obj, seismogram);
                obj.velocities(indexOfSeis,1) = velocity;
            end
        end

        function velocity = GetDirectWaveVelocityForSeismogram(obj, seismogram)
            firstTimes = seismogram.FirstTimes;
%             numbFigure = 2;
%             DataVisualizer.SetNumberOfFigure(numbFigure);
%             DataVisualizer.SetLabelX('Трасса');
%             DataVisualizer.SetLabelY('мс');
%             DataVisualizer.Clear();
%             DataVisualizer.PlotSeismogram(seismogram, 'g-', 1);
%             plot(1:length(firstTimes), -firstTimes, 'r*');

            firstTimes = CorrectionTimesOfBadSideFromGoodSide(obj, firstTimes, seismogram);
%             plot(1:length(firstTimes), -firstTimes, 'b+');

            leftIndices = GetLeftIndicesOfSensors(obj, seismogram);
            leftSideVelocity  = CalculationVelocityForOneSide(obj, seismogram, firstTimes, leftIndices);
            rightIndices = GetRightIndicesOfSensors(obj, seismogram);
            rightSideVelocity = CalculationVelocityForOneSide(obj, seismogram, firstTimes, rightIndices);
            leftRightVelocity = (leftSideVelocity + rightSideVelocity) / 2;
            velocity = leftRightVelocity * 1000;
        end

        function leftIndices = GetLeftIndicesOfSensors(obj, seismogram)
            indexOfCenter = seismogram.GetIndexOfSeismogramCenter;
            numberOfPoint = GetNumberOfPointForVelocityCalculation(obj, seismogram);
            leftIndices = indexOfCenter-numberOfPoint:indexOfCenter-1;
        end
        function rightIndices = GetRightIndicesOfSensors(obj, seismogram)
            indexOfCenter = seismogram.GetIndexOfSeismogramCenter;
            numberOfPoint = GetNumberOfPointForVelocityCalculation(obj, seismogram);
            rightIndices = indexOfCenter+1:indexOfCenter+numberOfPoint;
        end

        function numberOfPoint = GetNumberOfPointForVelocityCalculation(obj, seismogram)
            distanceBetwenTwoSensors = seismogram.GetDistanceBetwenTwoSensors();
            numberOfPoint = round(obj.maxDistanceForVelocityCalculation / distanceBetwenTwoSensors);
        end

        function curSTD = GetSTDForSensors(obj, indicesOfSensors, seismogram)
            Li = abs(seismogram.SourceX - seismogram.SensorsX);
            firstTimes = seismogram.FirstTimes;
            xLi = Li(indicesOfSensors);
            times = firstTimes(indicesOfSensors);
            pnLeft = polyfit(xLi, times, 1);
            calculatedTimes = polyval(pnLeft, xLi);
            curSTD = sqrt( sum((times-calculatedTimes).^2) / (length(times)-1) );
        end

        function firstTimes = CorrectionTimesOfBadSideFromGoodSide(obj, firstTimes, seismogram)
            indexOfGoodSide = GetIndexOfGoodSide(obj, seismogram);
            indicesOfSensors = GetIndicesOfGoodSide(obj, seismogram, indexOfGoodSide);
            indexOfCenter = seismogram.GetIndexOfSeismogramCenter;
            for indexOfGoodSideSensor = indicesOfSensors
                indexOfBadSideSensor = indexOfCenter + abs(indexOfCenter-indexOfGoodSideSensor);
                timeOfGoodSideSensor = firstTimes(indexOfGoodSideSensor);
                timeOfBadSideSensor = firstTimes(indexOfBadSideSensor);
                diffTime = abs(timeOfGoodSideSensor-timeOfBadSideSensor);
                if diffTime > obj.maxDiffTime
                    firstTimes(indexOfBadSideSensor) = timeOfGoodSideSensor;
                end
            end
        end

        function result = GetIndexOfGoodSide(obj, seismogram)
            result = 0;
            leftIndices = GetLeftIndicesOfSensors(obj, seismogram);
            leftSTD = GetSTDForSensors(obj, leftIndices, seismogram);
            rightIndices = GetRightIndicesOfSensors(obj, seismogram);
            rightSTD = GetSTDForSensors(obj, rightIndices, seismogram);
            if leftSTD < rightSTD
                result = -1;    % Left
            elseif leftSTD > rightSTD
                result = 1;     % Right
            end
        end

        function indicesOfSensors = GetIndicesOfGoodSide(obj, seismogram, indOfGoodSide)
            if indOfGoodSide == -1
                indicesOfSensors = GetLeftIndicesOfSensors(obj, seismogram);
                return;
            elseif indOfGoodSide == 1
                indicesOfSensors = GetRightIndicesOfSensors(obj, seismogram);
                return;
            end
            ME = MException('DirectWaveCalculator:GetIndicesOfGoodSide:WrongIndexOfGoodSide', ...
                'Wrong index of good side');
            throw(ME)
        end

        % Рассчет скорости по одной части сейсмотрасс
        function velocity = CalculationVelocityForOneSide(obj, seismogram, firstTimes, indicesOfSensors)
            timesOfSensors = [];
            sensorsX = [];
            Li = abs(seismogram.SourceX - seismogram.SensorsX);
            for i = indicesOfSensors
                if firstTimes(i) > 0
                    sensorsX(end+1) = Li(i);
                    timesOfSensors(end+1) = firstTimes(i);
                end
            end
            [indicesOfSensors, timesOfSensors] = RemoveOutburstLine(obj, indicesOfSensors, timesOfSensors);
            sensorsX = Li(indicesOfSensors);
            velocity = GetVelocityFromDistancesAndTimes(obj, sensorsX, timesOfSensors);
        end

        % Удаление выбросов
        function [resultIndices, resultSensors] = RemoveOutburstLine(obj, indicesOfSensors, timesOfSensors)
            [indicesOfSensors, ind] = sort(indicesOfSensors);
            timesOfSensors = timesOfSensors(ind);
            pn = polyfit(indicesOfSensors, timesOfSensors, 1);
            resultIndices = [];
            resultSensors = [];
            for i = 1:1:length(indicesOfSensors)
                indexOfSensor = indicesOfSensors(i);
                timeOfSensor = timesOfSensors(i);
                calculatedTime = polyval(pn, indexOfSensor);
                if abs(timeOfSensor-calculatedTime) < obj.timeDiapasonForRemoveOutburst
                    resultIndices = [resultIndices indexOfSensor];
                    resultSensors = [resultSensors timeOfSensor];
                end
            end
        end

        % Рассчет скорости по удалению и времени
        function velocity = GetVelocityFromDistancesAndTimes(obj, distances, times)
            mV = [];
            count = 1;
            for i = 1:1:length(times)-1
                for j = i+1:1:length(times)
                    if abs(times(i)-times(j)) > 0 && abs(i-j) > 1
                        dt(count) = abs(times(i)-times(j));
                        dx(count) = abs(distances(i)-distances(j));
                        mV(count) = dx(count)/dt(count);
                        count = count + 1;
                    end
                end
            end
            velocity = median(mV);
        end

    end
end