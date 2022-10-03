classdef SeismicDataPreparer < handle
    properties (Access = private)
        initialSeismicData (1,1) SeismicData
        spanForFirstTimes
        minTraceAmpForFirstTimes
    end

    properties (Dependent)
        InitialSeismicData
        SpanForFirstTimes
        MinTraceAmpForFirstTimes
    end

    methods
        function obj = SeismicDataPreparer()
        end

        function initialSeismicData = get.InitialSeismicData(obj)
            initialSeismicData = obj.initialSeismicData;
        end
        function set.InitialSeismicData(obj, initialSeismicData)
            obj.initialSeismicData = initialSeismicData;
        end

        function spanForFirstTimes = get.SpanForFirstTimes(obj)
            spanForFirstTimes = obj.spanForFirstTimes;
        end
        function set.SpanForFirstTimes(obj, spanForFirstTimes)
            obj.spanForFirstTimes = spanForFirstTimes;
        end

        function minTraceAmpForFirstTimes = get.MinTraceAmpForFirstTimes(obj)
            minTraceAmpForFirstTimes = obj.minTraceAmpForFirstTimes;
        end
        function set.MinTraceAmpForFirstTimes(obj, minTraceAmpForFirstTimes)
            obj.minTraceAmpForFirstTimes = minTraceAmpForFirstTimes;
        end

        function resultSeismicData = Prepare(obj)
            resultSeismicData = MakeSymmetricalSeismogramsFromInputSeismicData(obj, obj.initialSeismicData);
            resultSeismicData.CalculateFirstTimes(obj.spanForFirstTimes, obj.minTraceAmpForFirstTimes);
        end
    end

    methods (Access = private)
        % Удаление лишних сейсмотрасс пока сейсмограмма не будет симметричная
        function outputSeismicData = MakeSymmetricalSeismogramsFromInputSeismicData(obj, inputSeismicData)
            outputSeismicData = copy(inputSeismicData);
            numberOfSeis = length(inputSeismicData.Seismograms);
            for indexOfSource = 1:1:numberOfSeis
                newSeismorgam = MakeSymmetricalSeismogram(obj, inputSeismicData.Seismograms(indexOfSource));
%                 numbFigure = 1;
%                 DataVisualizer.SetNumberOfFigure(numbFigure);
%                 DataVisualizer.SetTitle(num2str(indexOfSource));
%                 DataVisualizer.SetLabelX('Трасса');
%                 DataVisualizer.SetLabelY('мс');
%                 DataVisualizer.Clear();
%                 DataVisualizer.PlotSeismogram(newSeismorgam, 'g-', 1);
                outputSeismicData.Seismograms(indexOfSource) = newSeismorgam;
            end
        end

        % Создать симетричную сейсмограмму на основе текущей
        function newSeismorgam = MakeSymmetricalSeismogram(obj, initialSeismogram)
            indexOfSeismogramCenter = initialSeismogram.IndexOfCentralSensor;
            maxDistance = initialSeismogram.GetMaximumAllowableDistanceFromSource();
            newNumberOfSensors = 2*maxDistance + 1;
            newTraces(1:newNumberOfSensors,1) = SeismicTrace();
            newSensorsX = zeros(1,newNumberOfSensors);
            index = 1;
            for indexOfSensor = 1:1:initialSeismogram.NumberOfSensors
                if indexOfSensor >= indexOfSeismogramCenter-maxDistance && indexOfSensor <= indexOfSeismogramCenter+maxDistance
                    newSensorsX(index) = initialSeismogram.SensorsX(indexOfSensor);
                    newTraces(index) = copy(initialSeismogram.Traces(indexOfSensor));
                    index = index + 1;
                end
            end
            newSeismorgam = copy(initialSeismogram);
            newSeismorgam.SensorsX = newSensorsX;
            newSeismorgam.Traces   = newTraces;
        end
        
    end
end