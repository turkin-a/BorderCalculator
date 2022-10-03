classdef DataVisualizer < IVisualizer
    properties (Access = private)
        figureObject matlab.ui.Figure
        numberOfFigure (1,1) double = 1
        titleName (1,:) char = []
        labelXName (1,:) char = []
        labelYName (1,:) char = []
    end

    methods (Access = private)
        function obj = DataVisualizer()
        end

        function UpdateFigure(obj)
            curFigureObject = GetFigureObject(obj);
            activeFigureObject = gcf;
            if ~isempty(activeFigureObject) && curFigureObject ~= activeFigureObject
                figure(curFigureObject);
                cla;
            end
            hold on;
        end

        function figureObject = GetFigureObject(obj)
            if IsFigureObjectExist(obj)
                figureObject = obj.figureObject;
            else
                obj.figureObject = figure(obj.numberOfFigure);
                figureObject = obj.figureObject;
            end
        end
        function result = IsFigureObjectExist(obj)
            result = false;
            if ~isempty(obj.figureObject) && isvalid(obj.figureObject) && isgraphics(obj.figureObject)
                result = true;
            end
        end
    end

    methods (Access = public, Static)
        function SetNumberOfFigure(numberOfFigure)
            obj = DataVisualizer.Instance();
            obj.numberOfFigure = numberOfFigure;
            obj.figureObject = figure(obj.numberOfFigure);
            hold on;
        end
        function numberOfFigure = GetNumberOfFigure()
            obj = DataVisualizer.Instance();
            numberOfFigure = obj.numberOfFigure;
        end

        function SetTitle(titleName)
            obj = DataVisualizer.Instance();
            obj.titleName = titleName;
        end

        function SetLabelX(labelXName)
            obj = DataVisualizer.Instance();
            obj.labelXName = labelXName;
        end

        function SetLabelY(labelYName)
            obj = DataVisualizer.Instance();
            obj.labelYName = labelYName;
        end

        function PlotSeismogram(seismogram, tipLineAndColor, lineWidth)
            traces = seismogram.Traces; 
            DataVisualizer.PlotTraces(traces, tipLineAndColor, lineWidth);
        end

        function PlotTraces(traces, tipLineAndColor, lineWidth)
            for indexOfTrace = 1:1:length(traces)
                trace = traces(indexOfTrace);
                DataVisualizer.PlotTrace(trace, indexOfTrace, tipLineAndColor, lineWidth);
            end
        end

        function PlotTrace(trace, indexOfTrace, tipLineAndColor, lineWidth)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            samples = trace.Samples;
            DataVisualizer.PlotSamples(samples, indexOfTrace, tipLineAndColor, lineWidth);
        end
        
        function PlotSamples(samples, indexOfTrace, tipLineAndColor, lineWidth)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            x = 1:1:length(samples);    
            amplitude = max(abs(samples));
            if amplitude == 0
                amplitude = 1;
            end
            plot(samples / (2*amplitude) + indexOfTrace, -x, tipLineAndColor, 'LineWidth', lineWidth);
        end

        function PlotSetOfIntervals(setOfIntervals, lineWidth, markerSize)
            for indexOfSensor = 1:1:length(setOfIntervals)
                intervals = setOfIntervals{indexOfSensor};
                DataVisualizer.PlotIntervals(intervals, lineWidth, markerSize);
            end
        end
        function PlotIntervals(intervals, lineWidth, markerSize)
            for i = 1:1:length(intervals)
                interval = intervals{i};
                DataVisualizer.PlotInterval(interval, lineWidth, markerSize);
            end
        end
        function PlotInterval(interval, lineWidth, markerSize)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            if interval.TypeOfInterval == IntervalType.Good
                plot([interval.IndexOfTrace interval.IndexOfTrace], -[interval.BeginTime interval.EndingTime], 'b-x', 'LineWidth', lineWidth, 'MarkerSize', markerSize);
            elseif interval.TypeOfInterval == IntervalType.Additional
                plot([interval.IndexOfTrace interval.IndexOfTrace], -[interval.BeginTime interval.EndingTime], 'c-x', 'LineWidth', lineWidth, 'MarkerSize', markerSize);
            elseif interval.TypeOfInterval == IntervalType.Bad
                plot([interval.IndexOfTrace interval.IndexOfTrace], -[interval.BeginTime interval.EndingTime], 'k-x', 'LineWidth', 1, 'MarkerSize', markerSize-5);
            end
        end

        function PlotHilbertInSetOfIntervals(setOfIntervals, absHilbertSeismogram, lineWidth, markerSize)
            for indexOfSensor = 1:1:length(setOfIntervals)
                intervals = setOfIntervals{indexOfSensor};
                absHilbertTrace = absHilbertSeismogram.Traces(indexOfSensor);
                DataVisualizer.PlotHilbertInIntervals(intervals, absHilbertTrace, lineWidth, markerSize);
            end
        end
        function PlotHilbertInIntervals(intervals, absHilbertTrace, lineWidth, markerSize)
            for i = 1:1:length(intervals)
                interval = intervals{i};
                DataVisualizer.PlotHilbertInInterval(interval, absHilbertTrace, lineWidth, markerSize)
            end
        end
        function PlotHilbertInInterval(interval, absHilbertTrace, lineWidth, markerSize)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            absHilbertSamples = absHilbertTrace.Samples;
            x = interval.BeginTime:interval.EndingTime;
            amplitude = max(abs(absHilbertSamples));
            if amplitude == 0
                amplitude = 1;
            end
            if interval.TypeOfInterval == IntervalType.Good
                plot(absHilbertSamples(x) / (2*amplitude) + interval.IndexOfTrace, -x, 'b-', 'LineWidth', lineWidth);
                plot(absHilbertSamples(x(1)) / (2*amplitude) + interval.IndexOfTrace, -x(1), 'bx', 'MarkerSize', markerSize);
                plot(absHilbertSamples(x(end)) / (2*amplitude) + interval.IndexOfTrace, -x(end), 'bx', 'MarkerSize', markerSize);
            elseif interval.TypeOfInterval == IntervalType.Additional
                plot(absHilbertSamples(x) / (2*amplitude) + interval.IndexOfTrace, -x, 'c-', 'LineWidth', lineWidth);
                plot(absHilbertSamples(x(1)) / (2*amplitude) + interval.IndexOfTrace, -x(1), 'cx', 'MarkerSize', markerSize);
                plot(absHilbertSamples(x(end)) / (2*amplitude) + interval.IndexOfTrace, -x(end), 'cx', 'MarkerSize', markerSize);
            end
        end

        function PlotSetOfTimes(setOfTimes, tipPointAndColor, markerSize)
            for indexOfSensor = 1:1:length(setOfTimes)
                times = setOfTimes{indexOfSensor};
                DataVisualizer.PlotTimes(indexOfSensor, times, tipPointAndColor, markerSize);
            end
        end
        function PlotTimes(indexOfSensor, times, tipPointAndColor, markerSize)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            plot(indexOfSensor, -times, tipPointAndColor, 'MarkerSize', markerSize);
        end

        function PlotSetOfPoints(setOfPoints, markerSize, lineWidth)
            for iSensor = 1:1:length(setOfPoints)
                points = setOfPoints{iSensor};
                if ~isempty(points)
                    DataVisualizer.PlotPoints(points, markerSize, lineWidth);
                end
            end
        end
        function PlotPoints(points, markerSize, lineWidth)
            for i = 1:1:length(points)
                point = points{i};
                DataVisualizer.PlotPoint(point, markerSize, lineWidth);
            end

        end
        function PlotPoint(point, markerSize, lineWidth)
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            currColor  = DataVisualizer.GetColorOfDirection(point.Direction);
            currMarker = DataVisualizer.GetMarkerOfDirection(point.Direction);
            markerSize = DataVisualizer.GetMarkerSizeOfPoint(point, markerSize);
            lineWidth  = DataVisualizer.GetLineWidthSizeOfPoint(point, lineWidth);
            plot(point.IndexOfSensor, -point.Time, [currColor currMarker], 'MarkerSize', markerSize, 'LineWidth', lineWidth);
        end
        function currColor = GetColorOfDirection(direction)
            switch direction
                case -1
                    currColor = 'b';
                case  1
                    currColor = 'r';
                otherwise
                    currColor = 'k';
            end
        end
        function currMarker = GetMarkerOfDirection(direction)
            switch direction
                case -1
                    currMarker = '<';
                otherwise
                    currMarker = '>';
            end
        end
        function resultMarkerSize = GetMarkerSizeOfPoint(point, markerSize)
            switch point.TypeOfInterval
                case IntervalType.Good
                    resultMarkerSize = markerSize+2;
                otherwise
                    resultMarkerSize = markerSize;
            end
        end
        function resultLineWidth = GetLineWidthSizeOfPoint(point, lineWidth)
            switch point.TypeOfInterval
                case IntervalType.Good
                    resultLineWidth = lineWidth+2;
                otherwise
                    resultLineWidth = lineWidth;
            end
        end
        



        function obj = Instance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = DataVisualizer();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end

        function obj = Clear()
            obj = DataVisualizer.Instance();
            UpdateFigure(obj);
            cla;
            hold on;
            if ~isempty(obj.titleName)
                title(obj.titleName);
            end
            if ~isempty(obj.labelXName)
                xlabel(obj.labelXName);
            end
            if ~isempty(obj.labelYName)
                ylabel(obj.labelYName);
            end
        end        
    end
end